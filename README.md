# Context-aware Mouse Behaviour Recognition using Hidden Markov Models
### Introduction

Automated recognition of mouse behaviours is crucial in studying psychiatric and neurologic diseases. To achieve
this objective, it is very important to analyse temporal dynamics of mouse behaviours. Here, we release the code of our paper for mouse behavior recognition in a video.

### Dataset
MIT dataset:

video can be downloaded from
http://serre-lab.clps.brown.edu/wp-content/themes/serre_lab/resources/full_database.zip

Extracted features can be downloaded from https://uniofleicester-my.sharepoint.com/:u:/g/personal/zj53_leicester_ac_uk/EftVtfnVP_hPtAH-Qx6fXxsBuDyPiXhfHnd6ppqfhB7zSg?e=6YObmJ

CMBR dataset:

video can be downloaded from https://www.dropbox.com/s/o6701i37yrzxq8b/mouse_video.zip?dl=0

Extracted features can be downloaded from https://uniofleicester-my.sharepoint.com/:u:/g/personal/zj53_leicester_ac_uk/EYG7U9IF_GBGjssinUjm5A0BkJGlZJmnhkAgClVrdJSFIA?e=fVTRWe

### Demo
Put feature data in `mouse_data/` and modify the path of feature data in initial_parameters, then run recognition_demo.

### Demonstrations of automated annotation

<p align="center">
<img src="https://github.com/BIPL-UoL/CMBR/blob/master/MIT_result.gif" height="220">
<img src="https://github.com/BIPL-UoL/CMBR/blob/master/QUB_result.gif"  height="220">
</p>

### Ethical proof

All experimental procedures were performed in accordance with the Guidance on the Operation of the Animals (Scientific Procedures) Act, 1986 (UK) and approved by the Queen’s University Belfast Animal.

### Citation

If you find CMBR useful in your research, please consider citing:

    @article{jiang2019context,
      title={Context-Aware Mouse Behavior Recognition Using Hidden Markov Models},
      author={Jiang, Zheheng and Crookes, Danny and Green, Brian D and Zhao, Yunfeng and Ma, Haiping and Li, Ling and Zhang, Shengping and
      Tao, Dacheng and Zhou, Huiyu},
      journal={IEEE Transactions on Image Processing},
      volume={28},
      number={3},
      pages={1133--1148},
      year={2019},
      publisher={IEEE}
    }
  
