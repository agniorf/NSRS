using DataFrames, OptimalTrees
using RDatasets, MLDataUtils, JLD

function fitOptTree(big_X, big_Y, test_X, test_Y; seed::Int=123, max_depth::Int=8, min_bucket::Array{Int64,1}=[1,5,10])
    srand(seed)
    (train_X, train_Y), (valid_X, valid_Y) = stratifiedobs((big_X, big_Y), p=0.67);
    lnr = OptimalTrees.OptimalTreeClassifier()
    lnr.treat_unknown_categoric_missing = true
    tree_params = Dict(
      :max_depth => 1:max_depth,
      :minbucket => min_bucket,
      #:criterion=>[:gini]
    )
    grid = OptimalTrees.GridSearch(lnr, tree_params)
    OptimalTrees.fit!(grid, train_X, train_Y, valid_X, valid_Y, validation_criterion=:auc, verbose=true)
    MisC = OptimalTrees.score(grid.best_lnr, test_X, test_Y, criterion=:misclassification)
    AUC = OptimalTrees.score(grid.best_lnr, test_X, test_Y, criterion=:auc)
    return MisC, AUC, grid.best_lnr, grid.best_params[:minbucket], grid.best_params[:max_depth]
 end


datapath = "../data/"
resultspath = ""

trainfilepath = joinpath(datapath, "Hematocritexperiment6noGluc_train.csv")
testfilepath = joinpath(datapath, "Hematocritexperiment6noGluc_test.csv")

train_data = readtable(trainfilepath, makefactors = true);
test_data = readtable(testfilepath, makefactors = true);

pool!(train_data,[:Gender,:AHT,:Nitrates,:Diuretics,:Smoking,:CVD,:Afib,:CABG_new,:PCI_new,:MI_new,:TIA_new,:Glucose_ur,:Albumin_ur,:XrayEnlar_before,:LVH,:Intravent_block,:Atrioventr_block,:T_wave,:ST_segment,:U_wave,:prem_beats,:Hypertension,:diabetes,:Statins])
pool!(test_data,[:Gender,:AHT,:Nitrates,:Diuretics,:Smoking,:CVD,:Afib,:CABG_new,:PCI_new,:MI_new,:TIA_new,:Glucose_ur,:Albumin_ur,:XrayEnlar_before,:LVH,:Intravent_block,:Atrioventr_block,:T_wave,:ST_segment,:U_wave,:prem_beats,:Hypertension,:diabetes,:Statins])

big_X = train_data[:,3:(end-2)]
test_X = test_data[:,3:(end-2)]
big_Y = train_data[:outcome]
test_Y = test_data[:outcome]

#Parameter selection
max_depth = 10
min_bucket = [20]
for i in min_bucket 
		min_bct=[i]
		MisC, AUC, lnr, minbucket, maxdepth = fitOptTree(big_X, big_Y, test_X, test_Y; max_depth=max_depth, min_bucket = min_bct)
		results = DataFrame(MisClas= MisC, AUC = AUC, min_bucket=minbucket ,max_depth = maxdepth)
		filepath_prediction_results = joinpath(resultspath, "Jan_late_prediction_results_$AUC,$minbucket,$maxdepth.csv")
		writetable(filepath_prediction_results, results)
		filepath_lnr = joinpath(resultspath, "Jan_late_Final_Cohort2_lnr_$AUC,$minbucket,$maxdepth.jld")
		@save filepath_lnr lnr
		OptimalTrees.showinbrowser(lnr)
end

##TESTING ON DAGOSTINO DATASET##
datapath = "../data/"
resultspath = ""

dagfilepath = joinpath(datapath, "oct_dat_for_agni.csv")

dag_data = readtable(dagfilepath, makefactors = true);
delete!(dag_data, :strokedate)

data = dag_data[:,3:(end-4)]
outcome = dag_data[:,:outcome]

OptimalTrees.score(lnr, data, outcome, criterion=:auc)



#Demonstration purposes
max_depth = 3
min_bucket = [100]
for i in min_bucket 
    min_bct=[i]
    MisC, AUC, lnr, minbucket, maxdepth = fitOptTree(big_X, big_Y, test_X, test_Y; max_depth=max_depth, min_bucket = min_bct)
    results = DataFrame(MisClas= MisC, AUC = AUC, min_bucket=minbucket ,max_depth = maxdepth)
    filepath_prediction_results = joinpath(resultspath, "example_prediction_results_$AUC,$minbucket,$maxdepth.csv")
    writetable(filepath_prediction_results, results)
    filepath_lnr = joinpath(resultspath, "example_Final_Cohort2_lnr_$AUC,$minbucket,$maxdepth.jld")
    @save filepath_lnr lnr
    OptimalTrees.showinbrowser(lnr)
end

#Try to check it
@load "Jan_late_Final_Cohort2_lnr_0.8743141674333026,20,8.jld"

