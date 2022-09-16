#!/usr/bin/env python3

import sys
import os, sys
import torch
import numpy as np
from omegaconf import OmegaConf
from PIL import Image
from einops import rearrange
from pytorch_lightning import seed_everything
from torch import autocast

from ldm.util import instantiate_from_config
from ldm.models.diffusion.plms import PLMSSampler


def load_model_from_config(config, ckpt, verbose=False):
    print(f"Loading model from {ckpt}")
    pl_sd = torch.load(ckpt, map_location="cpu")
    if "global_step" in pl_sd:
        print(f"Global Step: {pl_sd['global_step']}")
    sd = pl_sd["state_dict"]
    model = instantiate_from_config(config.model)
    m, u = model.load_state_dict(sd, strict=False)
    if len(m) > 0 and verbose:
        print("missing keys:")
        print(m)
    if len(u) > 0 and verbose:
        print("unexpected keys:")
        print(u)

    model.cuda()
    model.eval()
    return model


# split the input text file into paragraphs, each used a a set of prompt words
prompts = []
paragraph = ""
for line in sys.stdin:
    line = line.rstrip()
    if line == "":
        if len(paragraph) > 50:
            prompts.append(paragraph)
        paragraph = ""
    else:
        if paragraph != "":
            paragraph += " "
        paragraph += line.replace('"', "")

# create the directories that will be store the samples and prompts
os.makedirs("samples", exist_ok=True)
os.makedirs("prompts", exist_ok=True)

# initialize the model
seed_everything(42)
config = OmegaConf.load("../configs/stable-diffusion/v1-inference.yaml")
model = load_model_from_config(config, "../models/ldm/stable-diffusion-v1/model.ckpt")
device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu")
model = model.to(device)
sampler = PLMSSampler(model)

# run it, with no watermark / NSFW fall-back
base_count = 0
precision_scope = autocast
with torch.no_grad():
    with precision_scope("cuda"):
        with model.ema_scope():
            for prompt in prompts:
                uc = model.get_learned_conditioning([""])
                c = model.get_learned_conditioning(prompt)
                shape = [4, 512 // 8, 512 // 8]
                samples_ddim, _ = sampler.sample(
                    S=50,
                    conditioning=c,
                    batch_size=1,
                    shape=shape,
                    verbose=False,
                    unconditional_guidance_scale=7.5,
                    unconditional_conditioning=uc,
                    eta=0.0,
                    x_T=None,
                )

                x_samples_ddim = model.decode_first_stage(samples_ddim)
                x_samples_ddim = torch.clamp(
                    (x_samples_ddim + 1.0) / 2.0, min=0.0, max=1.0
                )
                x_samples_ddim = x_samples_ddim.cpu().permute(0, 2, 3, 1).numpy()
                x_image_torch = torch.from_numpy(x_samples_ddim).permute(0, 3, 1, 2)

                assert len(x_image_torch) == 1
                for x_sample in x_image_torch:
                    x_sample = 255.0 * rearrange(
                        x_sample.cpu().numpy(), "c h w -> h w c"
                    )
                    img = Image.fromarray(x_sample.astype(np.uint8))
                    img.save(os.path.join("samples", f"{base_count:05}.png"))

                    with open(f"prompts/{base_count:05}.txt", "w") as outfile:
                        outfile.write(str(prompt) + "\n")

                    base_count += 1
