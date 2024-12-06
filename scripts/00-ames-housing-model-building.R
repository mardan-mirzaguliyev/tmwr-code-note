# load necessary packages

library(tidymodels)

# log scale the Sale_Price
data(ames)
ames <- ames |> mutate(Sale_Price = log10(Sale_Price))


# Split the data into training and test sets
set.seed(502)
ames_split <- initial_split(ames, prop = 0.80, strata = Sale_Price)
ames_train <- training(ames_split)
ames_test  <-  testing(ames_split)


ames_rec <- 
  recipe(Sale_Price ~ Neighborhood + Gr_Liv_Area + Year_Built + Bldg_Type +
           Latitude + Longitude, data = ames_train) |> 
  step_log(Gr_Liv_Area, base = 10) |> 
  step_other(Neighborhood, threshold = 0.01) |> 
  step_dummy(all_nominal_predictors()) |> 
  step_interact( ~ Gr_Liv_Area:starts_with("Bldg_Type_")) |> 
  step_ns(Latitude, Longitude, deg_free = 20)


lm_model <- linear_reg() |> set_engine("lm")
lm_model

lm_wflow <- 
  workflow() |> 
  add_model(lm_model) |> 
  add_recipe(ames_rec)


lm_fit <- fit(lm_wflow, ames_train)


rf_model <- 
  rand_forest(trees = 1000) |> 
  set_engine("ranger") |> 
  set_mode("regression")


rf_wflow <- 
  workflow() |> 
  add_formula(
    Sale_Price ~ Neighborhood + Gr_Liv_Area + Year_Built + Bldg_Type +
      Latitude + Longitude) |> 
  add_model(rf_model)


set.seed(1001)
ames_folds <- vfold_cv(ames_train, v = 10)

keep_pred <- control_resamples(save_pred = TRUE, save_workflow = TRUE)

set.seed(1003)
rf_res <- rf_wflow |> fit_resamples(resamples = ames_folds, control = keep_pred)






