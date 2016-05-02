### tdms_struct data structure 

Every `Prod_<date>.mat` file is containing 2 variables, which are
* **field_names:** a cell array containing the list of fields of the *tdms_struct* 
**Note:** if not present can be easily generated using the command 

  ``` python
  field_names = fieldnames(tdms_struct)
  ```
* **tdms_struct:**  the real structure which is effectively containing the data
