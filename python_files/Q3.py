#student id: 21117851

import re
import numpy as np

def gettagssequence(alice_tag):
    file = open(alice_tag,'r') # Open the alice_tags file 
    tags_sequences = [] # Initialize empty tags_sequences list
    for line in file: # Run for loop for each line of the file
        tags_sequences.append(line.lower().replace('<sep>', '').strip()) # convert to lowercase, replace <sep> with '' 
                                                                         # Append it with tags_sequences list
    return tags_sequences # Return tags_sequences list

def getwordssequence(alice_word):
    file = open(alice_word,'r') # Read the file alice_words.txt
    words_sequences = [] # Initialize empty list words_sequences
    for line in file: # Run a for loop for each line in file
        words_sequences.append(line.lower().strip().split("<sep>")) # Convert all words to lower case, split the words by <sep>
                                                                    # Append it to the word_sequence list to create a list of list
    return words_sequences # Return the word_sequences list


def find_positions(tags_sequences): 
    matches_list = [] # Initialize empty tuple matches_list
    for tags_sequence in tags_sequences: # Run for loop for each tags_sequence
        tags_str = "".join(tags_sequence) # Concatenate it to  a string tags_str 
        noun_phrases = []                 # Initialize empty list noun_phrases
        for match in re.finditer(r"(?:J*N+)", tags_str, re.IGNORECASE): # Use re.finditer to find noun phrases after ignoring
                                                                        # the case
            start = match.start() # extract start position of noun phrase
            end = match.end()      #extract end position of noun phrase
            noun_phrases.append((start, end)) # Append start and end position of noun phrase to the list 
        matches_list.append(noun_phrases) # Append each of the list to the tuple matches_list
    return matches_list #return matches_list

def find_noun_phrases(input_word, matches_list, words_sequences):
    match_count = 0 # Initialize variable to iterate through the match list
    sentence_id = 1 # Initialize sentence id from 1
    for line in words_sequences: # run loop for each line in the words_sequences list 
        for match in matches_list[match_count]: # run loop for each  matches_list
            noun_phrase = line[match[0]:match[1]] # extract the noun phrase using the start and the end position number
            if input_word in noun_phrase:  # Check if input_word is present in noun phrase
               print(str(sentence_id) + ":" + ' '.join(noun_phrase))  # if input word is present, print in the required format
        match_count = match_count + 1 # Increase match count by 1
        sentence_id = sentence_id + 1 # Increase sentence id by 1
        
    return




