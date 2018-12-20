# TrainingDataset
Create a masked training dataset to use for public facing work

You can read the dataset directly into R by using the comands below. You must have the `readr` or `ICPIutilities` package installed.

### NOTES

- user must supply filepath for local PSNUxIM MSD
- requires having MSD (.txt) stored locally
- requires having planets_psnuuids2map.csv saved in Input which identifies the actual PSNUs that will be masked


```
#install packages
  install.packages("readr")
  install.packages("devtools")
  devtools::install_github("ICPI/ICPIutilities")
  
#import training dataset directly into R
  #dataset location
  dataset_url <- "https://raw.githubusercontent.com/ICPI/TrainingDataset/master/Output/MER_Structured_TRAINING_Dataset_PSNU_IM_FY17-18_20180622_v2_1.txt"
  
  #import with reader (will get some errors)
  df <- readr::read_tsv(dataset_url)

  #alternatively, you can use the read_msd() function from ICPIutilities (reads in all columns correctly)
  df <- ICPIutilities::read_msd(dataset_url, save_rds = FALSE)

```
