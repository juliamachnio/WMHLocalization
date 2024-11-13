close all
clear
clc

addpath('./NIFTI-Tool');

subjects = [0 2 4 6 8 11]; % A list of subjects 

% Reading the volumes
for i = subjects_train 
    
    %path to T1 image
    path_image = fullfile('./WMH/',num2str(i),'pre/T1.nii.gz');  

    %path to labels obtained by FAST-AID [M.M.Ghazi et al.]
    path_label = fullfile('./WMH/',num2str(i),'pre/T1_seg.nii.gz'); 

    fixedImageInfo = niftiRead(path_image, 'double', 'header'); % target volume info
    fixedImage = double(fixedImageInfo.img); % target image volume
    movingImageInfo = niftiRead('./JHU_MNI_SS_T1_seg.nii.gz', 'double', 'header'); % template volume info (T1 segmented with FAST-AID)
    movingImage = double(movingImageInfo.img); % template image volume
    movingLabelInfo = niftiRead('./JHU_MNI_SS_WMPM_Type-II.nii.gz', 'double', 'header'); % template segmentation info
    movingLabel = double(movingLabelInfo.img); % template label volume
    
    % Volume for WM segmentation
    fixedImageSegmentationInfo = niftiRead(path_label, 'double', 'header'); % target volume segmentation info 
    fixedImageSegmentation = double(fixedImageSegmentationInfo.img); % target volume segmentation info 
   
    % Removing labels that are not WM but were included, left side is set to label 200, right to 201 
    movingLabel(movingLabel == 26 | movingLabel == 27 | movingLabel == 28 | movingLabel == 56| movingLabel == 57 | movingLabel == 59 ...
        | movingLabel == 60 | movingLabel == 61 | movingLabel == 62 | movingLabel == 63 | movingLabel == 64 | movingLabel == 65) = 200;
    movingLabel(movingLabel == 91 | movingLabel == 92 | movingLabel == 93 | movingLabel == 121 | movingLabel == 122 | movingLabel == 124 ...
        | movingLabel == 125 | movingLabel == 126 | movingLabel == 127 | movingLabel == 128 | movingLabel == 129 | movingLabel == 130) = 201;
    
    %% Renumerating labels (required by YUCCA [S. Llambias et al.])

    movingLabel(movingLabel == 123) = 26;
    movingLabel(movingLabel == 120) = 27;
    movingLabel(movingLabel == 119) = 28;
    movingLabel(movingLabel == 118) = 56;
    movingLabel(movingLabel == 117) = 57;
    movingLabel(movingLabel == 107) = 59;
    movingLabel(movingLabel == 116) = 60;
    movingLabel(movingLabel == 115) = 61;
    movingLabel(movingLabel == 114) = 62;
    movingLabel(movingLabel == 113) = 63;
    movingLabel(movingLabel == 112) = 64;
    movingLabel(movingLabel == 111) = 65;
    movingLabel(movingLabel == 110) = 91;
    movingLabel(movingLabel == 109) = 92;
    movingLabel(movingLabel == 108) = 93;

    movingLabel(movingLabel == 200) = 107;
    movingLabel(movingLabel == 201) = 108;
    
    %%
    movingImageWM = movingImage; movingImageWM(~(movingImageWM == 44 | movingImageWM == 45)) = 0; %extracting WM regions 44 and 45 (WM Left and Right) and remaining these labels (atlas)
    fixedImageWM = fixedImageSegmentation; fixedImageWM(~(fixedImageWM == 44 | fixedImageWM == 45)) = 0; %extracting WM regions 44 and 45 and remaining these labels (WMH dataset)    
    
    %% Resizing the volumes to have the same resolution as the target volume
    
    newDimsImage = 2 * round(size(movingImageWM) .* dim_apply_xform(movingImageInfo.hdr.dime.pixdim(2 : 4), movingImageInfo.xform) ./ dim_apply_xform(fixedImageInfo.hdr.dime.pixdim(2 : 4), fixedImageInfo.xform) / 2); % nearest scaled even numbers
    movingImageWM = imresize3(movingImageWM, newDimsImage, 'linear', 'Antialiasing', true);
    newDimsLabel = 2 * round(size(movingLabel) .* dim_apply_xform(movingLabelInfo.hdr.dime.pixdim(2 : 4), movingLabelInfo.xform) ./ dim_apply_xform(fixedImageInfo.hdr.dime.pixdim(2 : 4), fixedImageInfo.xform) / 2); % nearest scaled even numbers
    movingLabel = imresize3(movingLabel, newDimsLabel, 'nearest', 'Antialiasing', false);
    % volumeViewer(movingImage, movingLabel)
    
    
    %% Volume registration
    [optimizer, metric] = imregconfig('multimodal');
    optimizer.InitialRadius = 0.0005; %less noisy on 0.005
    optimizer.Epsilon = 1e-4; %no need to modify
    optimizer.GrowthFactor = 1.01;
    optimizer.MaximumIterations = 5000;
    tform = imregtform(movingImageWM, fixedImageWM, 'affine', optimizer, metric);
    movingImageRegistered = imwarp(movingImage, tform, 'linear', 'OutputView', imref3d(size(fixedImage)));
    movingLabelRegistered = imwarp(movingLabel, tform, 'nearest', 'OutputView', imref3d(size(fixedImage)));
    
    %% Selecting atlas labels included in region 44 and 45 
    
    WMLabels = [44 45];
    fixedImageExtractedWM = ismember(fixedImageSegmentation, WMLabels);
    movingLabelRegistered = movingLabelRegistered.* fixedImageExtractedWM
    
    %% Save and view 

    % volumeViewer(movingImageRegistered, movingLabelRegistered)
    % volumeViewer(fixedImage, movingLabelRegisteredRemoved)

    movingLabelRegisteredInfo = fixedImageInfo;
    movingLabelRegisteredInfo.img = movingLabelRegistered;
    path_save = sprintf('./WMH_%s.nii.gz', num2str(i));
    niftiWrite(movingLabelRegisteredInfo, path_save, 'int16'); % save the predicted label map

end