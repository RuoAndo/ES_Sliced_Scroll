import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.metrics import r2_score


n = 500

x0 = np.linspace(0, 2 * np.pi, num=n)
# print(x0)
y_org = np.sin(x0)
# print(y_org)
y0 = np.sin(x0) + (np.random.rand(n)/5 - 0.5/5)
# print(y0)

plt.plot(x0, y0, label='data')
#plt.plot(x0, y_org, label='sin')
#sdf.plot(color=('r', 'b'))
plt.legend()
plt.show()
