# Deep Learning for Localization of White Matter (WM) Lesions in Neurological Diseases
This is the official repository of *Deep Learning for Localization of White Matter Lesions in Neurological Diseases* (https://openreview.net/pdf?id=ea0YJaJShO) presented at the Northern Lights Deep Learning Conference 2025.

## Description
White Matter Lesions are commonly observed as hyperintensities on FLAIR MRIs or hypointensities on T1-weighted images and associated with neurological diseases. The spatial distribution of these lesions is linked to an increased risk of developing neurological conditions, emphasizing the need for location-based analyses. This study proposes deep learning-based methods for automated WM lesions segmentation and localization.

## Method 
The pipeline consists of two steps:
- creating ground-truth WM region labels for individual scans (A),
- segmentation of lesions and regions and their analysis  (B).

Ultimately, the method provides both the localization and load of WM lesions, enabling the grouping of subjects based on regional lesion similarities and facilitating connections to neurological diseases.

  
![pipeline](https://github.com/juliamachnio/WMHLocalization/blob/main/img.jpg)

## Ground-truth WM region labels for individual scans
We used the JHU MNI atlas type II to obtain regional WM labels for model training [[atlas T1](https://github.com/muschellij2/Eve_Atlas/blob/master/JHU_MNI_SS_T1.nii.gz)] [[atlas labels](https://github.com/muschellij2/Eve_Atlas/blob/master/JHU_MNI_SS_WMPM_Type-II.nii.gz)] [[atlas labels txt](https://github.com/muschellij2/Eve_Atlas/blob/master/JHU_MNI_SS_WMPM_Type-II_SlicerLUT.txt)]. The original atlas contains 130 brain regions, 24 of which are non-white matter. We merged the remaining WM labels into 34 subregions based on their ontological relationships and clinical relevance [[refined labels](https://github.com/juliamachnio/WMHLocalization/blob/main/36_labels_merged.nii.gz)] [[refined labels txt](https://github.com/juliamachnio/WMHLocalization/blob/main/refined_atlas_labels.txt)].

We extracted WM from atlas T1 image and each subject's T1 using [FAST-AID](https://github.com/Mostafa-Ghazi/FAST-AID-Brain). Regions number 44 and 45 are WM left and WM right respectively. 
```bash
singularity run --nv fast_aid_brain.sif /input-dir-of-T1-img/ /output-dir/ 16 gpu weighted-majority uint8 1 2
```

The extracted WM from T1 atlas was registered to extracted WM from each subject's T1 image to estimate the affine transform. This transform is then applied to register the refined WM atlas labels to the subject's space, generating individual labels. We used a [multimodal intensity-based automatic image registration algorithm](https://se.mathworks.com/help/images/intensity-based-automatic-image-registration.html), applied
exclusively to the extracted WM regions from FAST-AID (see [matlab code (https://github.com/juliamachnio/WMHLocalization/blob/main/Create_WM_labels.m)).




## Lesions and regions segmentation

We trained four deep learning architectures: U-Net, UNETR, MultiResUNet and MedNeXt, to segment both WM lesions and anatomical WM regions, and combined the results to determine the location of WM lesions. We treated FLAIR and T1 images as a single modality to increase the number of training samples, improve robustness to intensity and modality variations, and enhance the model's generalizability in cases of missing data modalities. To further increase model robustness, we applied multiple augmentation techniques \cite{llambias2023data}, including additive and multiplicative noise, bias field addition, rotation, elastic deformation, and motion artifact simulation. Additionally, we used a weighted combination of cross-entropy (CE) loss, Dice-Sørensen (DS) loss, and skeleton recall (SR) loss, which has proven effective for segmenting thin, tubular structures and lesions \cite{kirchhoff2024skeleton}. 

Each DL architecture was trained using [Yucca](https://github.com/Sllambias/yucca/tree/main). 





## Citation
```bibtex
@inproceedings{
machnio2024deep,
title={Deep Learning for Localization of White Matter Lesions in Neurological Diseases},
author={Julia Machnio and Mads Nielsen and Mostafa Mehdipour Ghazi},
booktitle={Northern Lights Deep Learning Conference 2025},
year={2024},
url={https://openreview.net/forum?id=ea0YJaJShO}
}
```
