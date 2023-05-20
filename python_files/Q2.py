
#student id: 21117851

import numpy as np

def matrix_multiplication(*argv) -> np.ndarray:
    if len(argv) == 0:  # if no arguments are passed
        raise ValueError("No arguments")  # raise an error
    elif len(argv) == 1:  # if only one argument is passed
        return argv[0]  # return it
    # if dimensions of matrices are not compatible
    elif argv[0].shape[1] != argv[1].shape[0]:
        print("Matrix dimension mismatch")  # print an error message
        return None  # return None
    else:  # if more than one argument is passed
       
        # Initialize result array of zero.
        row = argv[0].shape[0]
        col = argv[1].shape[1]
        result = np.zeros(shape=(row, col))
        
         # write the full dot product algorithm
        for i in range(argv[0].shape[0]):  # for each row of the first matrix
            for j in range(argv[1].shape[1]):  # for each column of the second matrix
                # for each  row of the second matrix
                for k in range(argv[1].shape[0]):
                    # add the product of the elements to the result
                    result[i][j] += argv[0][i][k] * argv[1][k][j]
        # call the function recursively with the result and the rest of the arguments
        result = matrix_multiplication(result, *argv[2:])
        if (result is None):
            return None
        else:
            return result

def linear_solver(A,b):
   
    if type(A) is tuple  or type(b) is tuple: # If the input values are tuples, throw an error
       print("The Inputs are not suitable for a linear system of equations")
       return None
    
    else: 
    
      if A.shape[0] < len(b): # Print error message for Underdetermined system
         print("System is an Underdetermined system")
         print("This system has infinitely many solutions")
         return None
    
      if A.shape[0] > len(b): # Throw error message for Overdetermined system
         print("System is an Overdetermined system")
         print("This system has no solutions")
         return None

      if b.shape[1] != 1: # Throw an error message if the size of the inputs are not suitable for linear system of equation
         print("The Inputs are not suitable for a linear system of equations")
         return None
    
      if A.shape[0] !=len(b):  # Throw an error message if the size of the inputs are not suitable for linear system of equation
         print("The Inputs are not suitable for a linear system of equations")
         return None
       
      else: # If the linear system of equations can be calculated
         inverse_A = np.linalg.inv(A)  # Take inverse of A
         res = matrix_multiplication(inverse_A , b) # use the matrix_multiplication function to get the dot product of A inverse and b
         print("Unique solution")
         return res # return the unique solution

def LLS(A,b):
    A_transpose = np.transpose(A) # Take transpose of A
    A_1 = matrix_multiplication(A_transpose, A) # use matrix_multiplication function to calculate dot product of A transpose and A
    A_1_inv = np.linalg.inv(A_1) # get inverse of the value found above
    A_moore_penrose = matrix_multiplication(A_1_inv,A_transpose) # Use multiplication function to get dor product of the inverse found above and transpose of A
    X = matrix_multiplication(A_moore_penrose, b) # use matrix_multiplication function to calculate the dot product of value found above and b
    return X #return the value calculated 



