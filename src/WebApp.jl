using OptimalTrees, JLD


OptimalTrees.showquestionnaire(lnr)
OptimalTrees.showinbrowser(lnr)


#Change Categoric Variables to Questions
lnr.feature_data_.feature_names_categoric


lnr.feature_data_.feature_names_categoric[1] = "What is your Gender?"
lnr.feature_data_.feature_names_categoric[2] = "Are you taking Antihypertensive Drugs?"
lnr.feature_data_.feature_names_categoric[3] = "Are you taking Nitrates?"
lnr.feature_data_.feature_names_categoric[4] = "Are you taking Diuretics?"
lnr.feature_data_.feature_names_categoric[5] = "Are you a Smoker?"
lnr.feature_data_.feature_names_categoric[6] = "Do you have a Cardiovascular Disease?"
lnr.feature_data_.feature_names_categoric[7] = "Do you have Atrial Fibrillation?"
lnr.feature_data_.feature_names_categoric[8] = "Do you have Hypertension?"
lnr.feature_data_.feature_names_categoric[9] = "Have you performed a Coronary Artery Bypass Grafting (CABG) in the past?"
lnr.feature_data_.feature_names_categoric[10] = "Have you had a Myocardial Infarction (MI) in the past and how many?"
lnr.feature_data_.feature_names_categoric[11] = "Have you had a Transient Ischemic Attack (TIA) in the past?"
lnr.feature_data_.feature_names_categoric[12] = "Have you performed a Percutaneous Coronary Intervention (PCI) in the past?"





#Change Numeric Variables to Questions
lnr.feature_data_.feature_names_numeric

lnr.feature_data_.feature_names_numeric[1] = "How old are you? (years)"
lnr.feature_data_.feature_names_numeric[2] = "What is your Systolic Blood Pressure? (mmHg)"
lnr.feature_data_.feature_names_numeric[3] = "What is your Body Mass Index (BMI)? (kg/m^2)"
lnr.feature_data_.feature_names_numeric[4] = "What is your Hematocrit level? (percent %)"
lnr.feature_data_.feature_names_numeric[5] = "What is your Blood Glucose level? (mg/dl)"
lnr.feature_data_.feature_names_numeric[7]
lnr.feature_data_.feature_names_numeric[15] = "What is your High-density lipoprotein (HDL) level? (mg/dl)"






#Change cathegoric levels
lnr.feature_data_.categoric_index_to_level


lnr.feature_data_.categoric_index_to_level[1] = ["Unknown", "Male", "Female"]
lnr.feature_data_.categoric_index_to_level[2] = ["Unknown", "No", "Yes", "Maybe"]
### delete Maybe??
lnr.feature_data_.categoric_index_to_level[5] = ["Unknown", "No", "Yes"]
lnr.feature_data_.categoric_index_to_level[6] = ["Unknown", "No", "Yes"]
lnr.feature_data_.categoric_index_to_level[10] = ["Unknown", "No Infarction", "1 Infarction", "2 Infarctions", "3 Infarctions"]
lnr.feature_data_.categoric_index_to_level[11] = ["Unknown", "No", "Yes"]



	@save "variables_for_questionnaire.jld" lnr
	





