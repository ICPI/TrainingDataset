# PEPFAR MSD Training Dataset

This reposititory houses the PEPFAR MSD-stle training dataset to use for testing and public facing work. This is a dummy dataset that should be used for testing, training, and demoing instead of using actual data.

You can [download the dataset](https://github.com/ICPI/TrainingDataset/raw/master/Output/MER_Structured_TRAINING_Dataset_PSNU_IM_FY17-18_20181221_v2_1.txt) or read the dataset directly into R by using the commands below. 

To use with R, you must have the `readr` and `ICPIutilities` package installed.

```
## IMPORT MASKED TRAINING DATASET

#install packages
  install.packages("readr")
  install.packages("devtools")
  devtools::install_github("ICPI/ICPIutilities")
  
#import training dataset directly into R
  #dataset location
  dataset_url <- "https://raw.githubusercontent.com/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Dataset_PSNU_IM_FY17-18_20181221_v2_1.txt"
  
  #import with reader (will get some errors)
  df <- readr::read_tsv(dataset_url)

  #alternatively, you can use the read_msd() function from ICPIutilities (reads in all columns correctly)
  df <- ICPIutilities::read_msd(dataset_url, save_rds = FALSE)

```

Users also have the options of building a masked dataset. To do so requires the users to have (1) the current PEPFAR MSD PSNUxIM and (2) supply a list of 15 PSNU UIDS. These PSNU UIDS will be used to filter the dataset to keep only those districts identified. For the list used to produce the official MSD Training dataset, you can contact ICPI/DIV.

```
## BUILD MASKED TRAINING DATASET

  #install packages
    install.packages("devtools")
    devtools::install_github("ICPI/ICPIutilities")
  
  #filepath for MSD (.txt)
    msd_filepath <- "~/ICPI/Data/MER_Structured_Dataset_PSNU_IM_FY17-18_20181115_v1_2.txt"
    
  #supply list of PSNU UIDs to use 
    #these are dummy PSNU UIDs; user must change
    #to get the list used quarterly, contact ICPI/DIV
    psnuuid_list <- c("QlWUt1rBsEo", "GfzVv4oeclF", "PNgOI7VPe98", "TWpkDEvK6si", "aqktQTp0wHa", 
                      "XFdvhW8Ga1S", "sVwvt4bYesp", "EJDcY4F1rsj", "nXEQ97b2YHJ", "DfXQBOLWwbZ", 
                      "aC69ENcI2hU", "PJpAerXQjZ7", "PAj75tgxkIU", "Wru5kJQ36GT", "HB75Phs4wZL")
                      
  #generate training dataset
    mask_msd(msd_filepath, psnuuid_list) 
    
  #alternatively, save to a training dataset to a different folder than the MSD folder
    mask_msd(msd_filepath, psnuuid_list, "~/Output") 
```
