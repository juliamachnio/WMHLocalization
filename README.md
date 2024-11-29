# Deep Learning for Localization of White Matter Lesions in Neurological Diseases
This is the official repository for the paper "Deep Learning for Localization of White Matter Lesions in Neurological Diseases", presented at the Northern Lights Deep Learning Conference 2025.

## Description
White Matter Lesions are commonly observed as hyperintensities on FLAIR MRIs or hypointensities on T1-weighted images and associated with neurological diseases. The spatial distribution of these lesions is linked to an increased risk of developing neurological conditions, emphasizing the need for location-based analyses. This study proposes deep learning-based methods for automated WM lesions segmentation and localization.

## Method 
The pipeline consists of two steps:
- (A) creating ground-truth WM region labels for individual scans,
- (B) segmentation of lesions and regions and their analysis.

  
![pipeline](https://github.com/juliamachnio/WMHLocalization/blob/main/img.jpg)

## Ground-truth WM region labels for individual scans
We used the JHU MNI atlas type II to obtain regional WM labels for model training ([atlas T1 nifti](https://github.com/muschellij2/Eve_Atlas/blob/master/JHU_MNI_SS_T1.nii.gz), [atlas labels nifti](https://github.com/muschellij2/Eve_Atlas/blob/master/JHU_MNI_SS_WMPM_Type-II.nii.gz), [atlas labels txt](https://github.com/muschellij2/Eve_Atlas/blob/master/JHU_MNI_SS_WMPM_Type-II_SlicerLUT.txt)). The original atlas contains 130 brain regions, 24 of which were non-white matter. We merged the remaining WM labels into 34 subregions based on their ontological relationships and clinical relevance [refined labels nifti](https://github.com/juliamachnio/WMHLocalization/blob/main/36_labels_merged.nii.gz) [refined labels txt](https://github.com/juliamachnio/WMHLocalization/blob/main/refined_atlas_labels.txt).

First, WM regions are segmented in the subject and the atlas using [FAST-AID](https://github.com/Mostafa-Ghazi/FAST-AID-Brain). 


## Lesions and regions segmentation









Overview of the proposed methods for WM lesion and region segmentation. (A) The process for creating ground-truth WM region labels for individual scans. First, WM regions are segmented \cite{ghazi2022fast} in the subject and the atlas. The atlas WM is then registered to the subject's WM using affine transforms, and these transforms are applied to map the atlas labels into the subject's anatomical space. (B) Deep learning pipeline for regional WM lesion segmentation and analysis. Two deep networks are trained on T1 and FLAIR images for segmenting WM lesions and for segmenting WM regions. The predictions from these models are combined to provide regional WM lesions for each subject. The regional lesion loads are then calculated and used for clustering to explore associations with various neurological conditions.

The proposed WM lesion segmentation and localization methods involve two main components, as shown in Figure \ref{method_diagram} (B). The first component includes training deep learning networks for WM lesion segmentation, while the second focuses on WM region segmentation. Figure \ref{method_diagram} (A) outlines the process for generating WM region ground-truth labels, which are necessary for training the deep learning models for WM region segmentation. This labelling process is performed once before model training. Ultimately, the method provides both the localization and load of WM lesions, enabling the grouping of subjects based on regional lesion similarities and facilitating connections to neurological diseases.


czym są labelled , link do orginalnego atlasu, link to txt z labelami refined, jak wydobyć WM, link do yucca, przykładowe komendy do yucca, tabela z wynikami, cytowanie, rehectracja atlasu do subjectu za pomocą skryptu w matlabie 


## Citation

If you find this tutorial useful for your research, please consider citing our paper:

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
