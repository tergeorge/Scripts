
#student id: 21117851
import re
import numpy as np

def count_repetition(s, i):
    # counts the number of consecutive chars starting at index i, ignoring
    # uppercase/lowercase
    count = 1
    for j in range(i, len(s)-1):
        if(s[j].lower() == s[j+1].lower()):
            count += 1
        else:
            return count
    return count


def changeLetterCase(letter, toUpper):
    # changes letter to lowercase or uppercase
    # changeLetterCase('a', True) => 'A'
    # changeLetterCase('A', False) => a'
    if toUpper:
        return letter.upper()
    return letter.lower()


def shift_vowels(s):
    vowels = ["a", "e", "i", "o", "u"] # Initialize list of vowels
    size = len(vowels) # find length of vowels array

    new_word = "" # Initialize empty string for storing the new word
    j = 0

    while(j < len(s)): # run while loop till its less than size of string entered

        letter = s[j].lower()
        isUpperCase = s[j].isupper()

        if letter in vowels: # Check if letter is found in vowels array
        # get position of current vowel in `vowels`
            i = vowels.index(letter)

            # count number of consecutive letters
            steps = count_repetition(s, j)

            # get replacement vowel
            new_vowel = vowels[(steps+i+1) % size]

            # update consecutive vowels taking into consideration
            # uppercase/lowercase
            for step in range(0, steps):
                isUpperCase = s[j].isupper()

                new_word += changeLetterCase(
                    new_vowel, isUpperCase)
                j += 1
        
        else:
            new_word += changeLetterCase(letter, isUpperCase) # if letter is not a vowel , do not replace it
            j += 1
    
            
    return new_word # return new word
    


def sum_of_digits(s):
    print_statement = "The sum of digits operation performs"
    sum_digits = 0 # Initialize sum of digits as 0
    non_digits = [] # Create an empty array to store non-digits
    if len(s) == 0: #Check if string is empty
        print("Empty string entered!")  # Print message informing about empty string
    else:    
      for x in s: # Loop through each element in string s
          if x.isdigit() == True: # Check if x is a digit
             sum_digits = sum_digits +int(x) # If its a digit, add it to sum_digits
             print_statement = print_statement + ' ' + (x) # Creating the required print statement
             print_statement = print_statement + ' ' + ('+')
           
          else:
             non_digits.append(x) # if its not a digit, add it to the list of non-digits
        
      if sum_digits == 0: #Check if no digits are found in the string
          print("The sum of digits operation could not detect a digit!") #Print the required message 
          print("The returned input letters are:", non_digits)
    
      else:
          print_statement = print_statement[:-2]
          print(print_statement)
          print("The extracted non-digits are:", non_digits)  #Generate required print messages. 
             
        
    
    return sum_digits   # Return sum of digits





