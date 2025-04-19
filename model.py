#!/usr/bin/env python3
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error
from sklearn.model_selection import train_test_split

def main():
    # 1. Load the exported CSV
    df = pd.read_csv("data/training_data.csv")
    
    # 2. Preview the data
    print("=== Training Data Preview ===")
    print(df.head(), "\n")
    
    # 3. Define features and target
    X = df[["service_copay", "coinsurance_share"]]
    y = df["actual_student_pay"]
    
    # 4. Split into train and test sets
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # 5. Train a baseline linear regression model
    model = LinearRegression()
    model.fit(X_train, y_train)
    
    # 6. Evaluate the model
    y_pred = model.predict(X_test)
    mae = mean_absolute_error(y_test, y_pred)
    print(f"Baseline Linear Regression MAE: {mae:.2f}")

if __name__ == "__main__":
    main()
