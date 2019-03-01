# Context-aware Mouse Behaviour Recognition using Hidden Markov Models
### Introduction

Automated recognition of mouse behaviours is crucial in studying psychiatric and neurologic diseases. To achieve
this objective, it is very important to analyse temporal dynamics of mouse behaviours. Here, we release the code in our paper for mouse behavior recognition in a video.

### Dataset

http://serre-lab.clps.brown.edu/wp-content/themes/serre_lab/resources/full_database.zip

### Demo
* `data/` - Put datasets (images and/or detections) here. Images are expected to be in `<path/to/sequence>/images/`, and detections in `<path/to/sequence>/model-type` (this is also where custom detections will be put). Sequence maps should exist in `data/seqmaps` (an example file is given). Tracking output will be in `data/result/<same/structure/as/dataset>/<sequence-name>.txt`.

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
  
