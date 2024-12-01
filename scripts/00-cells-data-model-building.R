library(tidymodels)


data(cells)


cells <- cells |> select(-case)

set.seed(1304)
cell_folds <- vfold_cv(cells)

roc_res <- metric_set(roc_auc)


