#!/usr/bin/env python

from argparse import ArgumentParser
import nibabel as nib


def main():
    parser = ArgumentParser('4dtrim')
    parser.add_argument("image", help="4D image to trim in the 4th dimension")
    parser.add_argument("trimmed", help="Trimmed 4D image")
    parser.add_argument("--len", "-l", action="store", type=int, default=200,
                        help="target 4th dimension length")

    inputs = parser.parse_args()
    finp = inputs.image
    fout = inputs.trimmed
    length = inputs.len

    image = nib.load(finp)
    print(image.shape)

    if image.shape[3] <= length:
        print("Image already desired length or shorter - nothing to do")
    else:
        image_data = image.get_data()
        trimmed_data = image_data[:,:,:,:length]
        trimmed_image = nib.Nifti1Image(trimmed_data,
                                        header=image.header,
                                        affine=image.affine)
        trimmed_image.update_header()
        nib.save(trimmed_image, fout)
        print(trimmed_image.shape)


if __name__ == "__main__":
    main()
