import numpy as np
from scipy.optimize import curve_fit
import matplotlib.pyplot as plt

# Define the nonlinear model function
def nonlinear_model(x, c0, c1, a, b):
    return (c0 + c1 * (1 - x)) / (1 + np.exp(-(a * (x + b))**2))

# Generate some sample data
np.random.seed(42)
X = np.random.rand(100)
Y = nonlinear_model(X, 337, -100, 3.5, 0.08) + 0.05 * np.random.randn(100)

# Initial guess for the parameters
initial_guess = [300, 90, 2.5, 0.1]

# Fit the model to the data using curve_fit
params, covariance = curve_fit(nonlinear_model, X, Y, p0=initial_guess)

# Extract the fitting coefficients
a_fit, b_fit, c0_fit, c1_fit = params

print("Fitted coefficients:")
print(f"a: {a_fit}")
print(f"b: {b_fit}")
print(f"c0: {c0_fit}")
print(f"c1: {c1_fit}")

# Plot the scatter plot of the data
plt.scatter(X, Y, label='Data')

# Plot the fitted curve
X_fit = np.linspace(0, 1, 100)
Y_fit = nonlinear_model(X_fit, a_fit, b_fit, c0_fit, c1_fit)
plt.plot(X_fit, Y_fit, color='red', label='Fitted Curve')
plt.gca().invert_xaxis()
# Add labels and legend
plt.xlabel('X')
plt.ylabel('Y')
plt.legend()

# Show the plot
plt.savefig("example_Quadratic_Logistic_LM_fitting.png")

