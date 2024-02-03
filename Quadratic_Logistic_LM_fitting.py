import numpy as np
from scipy.optimize import curve_fit
# import matplotlib.pyplot as plt
import h5py
import sys

###  warning!!! 
## DO NOT print any additional variables, it will be returned as regression coefficients in the NCL Script

# Define the nonlinear model function
def nonlinear_model(x, c0, c1, a, b):
    return (c0 + c1 * (1 - x)) / (1 + np.exp(-1*(a * (x + b))**2))

ch=int(sys.argv[1])
pj=int(sys.argv[2])

TA_file=h5py.File(f"Ta_mu_pairs/Ta_mu_pairs_ch{ch:02d}_pj{pj:02d}.h5",'r')
Y =TA_file['Ta'][:]
X =TA_file['miu'][:]
TA_file.close()

# Initial guess for the parameters
initial_guess = [300, 90, 2.5, 0.1]

# Fit the model to the data using curve_fit
params, covariance = curve_fit(nonlinear_model, X, Y, p0=initial_guess)

# Extract the fitting coefficients
c0_fit, c1_fit, a_fit, b_fit = params

# # retrun to NCL, Do not comment them
print(f"{c0_fit}")
print(f"{c1_fit}")
print(f"{a_fit}")
print(f"{b_fit}")

# # Plot the scatter plot of the data
# plt.scatter(X, Y, label='Data')

# # Plot the fitted curve
# X_fit = np.linspace(0, 1, 100)
# Y_fit = nonlinear_model(X_fit, c0_fit, c1_fit, a_fit, b_fit)
# plt.plot(X_fit, Y_fit, color='red', label='Fitted Curve')
# plt.gca().invert_xaxis()
# # Add labels and legend
# plt.xlabel(f'\mu')
# plt.ylabel('Ta (K)')
# plt.legend()

# # Show the plot
# plt.savefig(f"Quadratic_Logistic_LM_fitting_ch{ch:02d}_pj{pj:02d}.png")
# plt.close()
