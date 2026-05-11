# bossing and MLP models transformation



# python codes
# -------------------- AdaBoost -------------------------
# # create pipeline for adaboost

# ada_pipe = Pipeline([
#     ("preprocess", preprocess),
#     ("adaboost", AdaBoostRegressor(
#         estimator=DecisionTreeRegressor(random_state=42),
#         random_state=42
#     ))
# ])


# n_estimators_range = range(1, 500, 10)

# param_grid = {
#     'adaboost__n_estimators': list(range(1, 500, 10)),
#     'adaboost__learning_rate': [0.0001,0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
#     'adaboost__estimator__max_depth': [1, 2, 3],
#     'adaboost__estimator__min_samples_leaf': [5, 10]
# }

# ada_search = GridSearchCV(
#     estimator=ada_pipe,
#     param_grid=param_grid,
#     scoring="neg_root_mean_squared_error",
#     cv=tscv,
#     n_jobs=-1,
#     verbose=1
# )

# ada_search.fit(X_train, y_train)

# print("Best AdaBoost params:", ada_search.best_params_)
# print("Best CV RMSE:", -ada_search.best_score_)


# best_ada = ada_search.best_estimator_

# val_pred = best_ada.predict(X_val)
# val_metrics = eval_reg(y_val, val_pred)

# print("Validation metrics (AdaBoost):", val_metrics)

# X_trainval = pd.concat([X_train, X_val], axis=0)
# y_trainval = pd.concat([y_train, y_val], axis=0)

# best_ada.fit(X_trainval, y_trainval)

# test_pred = best_ada.predict(X_test)
# test_metrics = eval_reg(y_test, test_pred)

# print("Final AdaBoost test metrics:", test_metrics)



# -------------------- MLP -------------------------
# # initial testing on the 
# mlp_base = MLPRegressor(
#     hidden_layer_sizes=(128, 64),
#     activation="relu",
#     solver="adam",
#     alpha=1e-3,               # L2 regularization
#     learning_rate_init=1e-3,
#     early_stopping=True,      # uses internal split from train only
#     n_iter_no_change=20,
#     max_iter=500,
#     random_state=42
# )

# mlp_base.fit(X_train_scaled, y_train)

# val_pred = mlp_base.predict(X_val_scaled)
# print("Validation metrics (MLP baseline):", eval_reg(y_val, val_pred))

# # create pipeline for MLP
# mlp_pipe = Pipeline([
#     ("preprocess", preprocess),
#     ("mlp", MLPRegressor(
#         solver="adam",
#         early_stopping=True,
#         n_iter_no_change=20,
#         max_iter=1000,
#         random_state=42
#     ))
# ])


# param_dist = {
#     "mlp__hidden_layer_sizes": [(32,), (64,), (128,), (128, 64), (256, 128), (256, 128, 64)],
#     "mlp__activation": ["relu", "tanh"],
#     "mlp__alpha": [1e-5, 1e-4, 1e-3, 1e-2, 5e-2],
#     "mlp__learning_rate_init": [1e-4, 3e-4, 1e-3, 3e-3, 5e-3, 1e-2],
#     "mlp__batch_size": [32, 64, 128, 256],
# }

# mlp_search = RandomizedSearchCV(
#     estimator=mlp_pipe,
#     param_distributions=param_dist,
#     n_iter=40,
#     scoring="neg_root_mean_squared_error",
#     cv=tscv,
#     random_state=42,
#     n_jobs=-1,
#     verbose=1
# )

# mlp_search.fit(X_train, y_train)
# best_mlp = mlp_search.best_estimator_

# val_pred = best_mlp.predict(X_val)
# print("MLP Val:", eval_reg(y_val, val_pred))


# best_mlp = mlp_search.best_estimator_

# val_pred = best_mlp.predict(X_val)
# print("Validation metrics (MLP tuned):", eval_reg(y_val, val_pred))


# # Combine train+val
# X_trainval = pd.concat([X_train, X_val], axis=0)
# y_trainval = pd.concat([y_train, y_val], axis=0)

# # Refit best MLP on train+val
# best_mlp = mlp_search.best_estimator_
# best_mlp.fit(X_trainval, y_trainval)

# # Test once
# test_pred = best_mlp.predict(X_test)
# print("Final MLP test metrics:", eval_reg(y_test, test_pred))

# -------------------- MLP Log -------------------------
# y_train_log = np.log1p(y_train)

# # create pipeline for MLP log transformation
# mlp_pipe = Pipeline([
#     ("preprocess", preprocess), 
#     ("mlp", MLPRegressor(
#         solver="adam",
#         early_stopping=True,
#         n_iter_no_change=20,
#         max_iter=1000,
#         random_state=42
#     ))
# ])

# log_mlp = TransformedTargetRegressor(
#     regressor=mlp_pipe,
#     func=np.log1p,
#     inverse_func=np.expm1
# )

# param_dist = {
#     "mlp__hidden_layer_sizes": [(32,), (64,), (128,), (128,64), (256,128), (256,128,64)],
#     "mlp__activation": ["relu", "tanh"],
#     "mlp__alpha": [1e-5, 1e-4, 1e-3, 1e-2, 5e-2],
#     "mlp__learning_rate_init": [1e-4, 3e-4, 1e-3, 3e-3, 5e-3, 1e-2],
#     "mlp__batch_size": [32, 64, 128, 256],
# }

# mlp_log_search = RandomizedSearchCV(
#     estimator=mlp_pipe,
#     param_distributions=param_dist,
#     n_iter=40,
#     scoring="neg_root_mean_squared_error",
#     cv=tscv,
#     n_jobs=-1,
#     random_state=42,
#     verbose=1
# )

# mlp_log_search.fit(X_train, y_train_log)


# best_log_mlp = mlp_log_search.best_estimator_

# val_pred = best_log_mlp.predict(X_val)
# print("MLP (log target) Val:", eval_reg(y_val, val_pred))


# X_trainval = pd.concat([X_train, X_val], axis=0)
# y_trainval = pd.concat([y_train, y_val], axis=0)

# final_log_mlp = mlp_log_search.best_estimator_
# final_log_mlp.fit(X_trainval, y_trainval)

# test_pred = final_log_mlp.predict(X_test)
# print("MLP (log target) Test:", eval_reg(y_test, test_pred))
