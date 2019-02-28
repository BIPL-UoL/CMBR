function [encode, normalize, gmm1_Size, gmm2_Size,dataset,stack_parameter] = initial_parameters()

stack_parameter.stackGrid=[2,2,1];
stack_parameter.stride_sp=20;
stack_parameter.stride_t=5;
stack_parameter.ThrDT= 60;
encode = 'fv';
normalize = 'Power-L2';
gmm1_Size = 20;
gmm2_Size=20;
dataset = 'F:\ECIT\mycomputer\MATLAB\CMBR_code_our_dataset\mouse_data';

end