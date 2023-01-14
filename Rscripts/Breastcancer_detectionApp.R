#Shiny Application for breast cancer detection using ML algorithms
# ML algorithms used: Random forest and neural network model

library(shiny)
library(caret)
library(neuralnet)
# Define UI for application 
ui <- fluidPage(

    # Application title
    titlePanel(" Breast Cancer Detection App"),
    # We are using 3 tabs
    tabsetPanel(
        id = "tabs",
        tabPanel(
            # Tab 1 shows all the features of the dataset
            title="Features",
                 sidebarLayout(
                     sidebarPanel(
                         h3("All Data Features") 
                     ),  
                     # Show a plot of all the features for benign and malignant tumor.
                     mainPanel(
                         plotOutput("feature")
                        
                     )
                 )       
                 
                 
                 ),
        tabPanel(
            # Tab 2 is used for neural network prediction model
            title="Neural Network",
            sidebarLayout(
                sidebarPanel(
                  # Type of tumor is classified with features marginal_adhesion, bare_nuclei and bland_chromatin
                    numericInput("marginal_adhesion","marginal_adhesion",1),
                    
                    
                    numericInput("bare_nuclei","bare_nuclei", 1),
                    
                    
                    numericInput("bland_chromatin","bland_chromatin",1)
                ),  
                
                mainPanel(
                    h3("Type of Tumor"),
                    tableOutput("classoutput")
                    
                )
            )      
            
            
            
        ),
        tabPanel(
            # Tab 3 is used for Random forest algorithm
            title = "Random Forest Algorithm",   
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            numericInput("Clumpthickness","Clumpthickness value:",1),
       
        
            numericInput("Uniofcsize","Uniformity of cell size:", 1),
     
     
            numericInput("Uofcellshape","Uniformity of cell shape:",1)
      ),  
        # The type of cancer is predicted based on features uniformity of cell shape,uniformity of cell size and clump thickness
     mainPanel(
         
          h3("Type of Tumor"),
          tableOutput("tab"),
          h3("Prediction with all test data"),
          plotOutput("distPlot")
           
        )
  )
        )
  
  ))
 

# Define the server 
server <- function(input, output) {
# Downloading the data
    output$distPlot <- renderPlot({
        bc_data <- read.table("C://Users//Teresa George//Documents//breast-cancer-wisconsin.txt", 
                              header = FALSE, 
                              sep = ",")
        # Adding column names
        colnames(bc_data) <- c("sample_code_number", 
                               "clump_thickness", 
                               "uniformity_of_cell_size", 
                               "uniformity_of_cell_shape", 
                               "marginal_adhesion", 
                               "single_epithelial_cell_size", 
                               "bare_nuclei", 
                               "bland_chromatin", 
                               "normal_nucleoli", 
                               "mitosis", 
                               "classes")
        
        bc_data$classes <- ifelse(bc_data$classes == "2", "benign",
                                  ifelse(bc_data$classes == "4", "malignant", NA))
        
        
        library(mice)
        
        bc_data[,2:10] <- apply(bc_data[, 2:10], 2, function(x) as.numeric(as.character(x)))
        dataset_impute <- mice(bc_data[, 2:10],  print = FALSE)
        bc_data <- cbind(bc_data[, 11, drop = FALSE], mice::complete(dataset_impute, 1))
        
        set.seed(42)
        index <- createDataPartition(bc_data$classes, p = 0.7, list = FALSE)
        train_data <- bc_data[index, ]
        test_data  <- bc_data[-index, ]
        set.seed(42)
        # Building the random forest model for prediction with number of folds 10 and returns as 15
        model_rf <- caret::train(classes ~ .,
                                 data = train_data,
                                 method = "rf",
                                 preProcess = c("scale", "center"),
                                 trControl = trainControl(method = "repeatedcv", 
                                                          number = 10, 
                                                          repeats = 15, 
                                                          savePredictions = TRUE, 
                                                          verboseIter = FALSE))
        
        results <- data.frame(actual = test_data$classes,
                              predict(model_rf, test_data, type = "prob"))
        # classified as benign or malignant based on the probalility
        # Graphs showing the prediction of all test data
        results$prediction <- ifelse(results$benign > 0.5, "benign",
                                     ifelse(results$malignant > 0.5, "malignant", NA))
        
        results$correct <- ifelse(results$actual == results$prediction, TRUE, FALSE)
        ggplot(results, aes(x = prediction, y = malignant, color = correct, shape = correct)) +
            geom_jitter(size = 3, alpha = 0.5)
               })
    
    output$tab <- renderTable({
      # Random forest model is used to predict the class(benign or malignant) based on inputed feature values
      train_data2=train_data[,1:4]
      model_rf2 <- caret::train(classes ~ .,
                                data = train_data2,
                                method = "rf",
                                preProcess = c("scale", "center"),
                                trControl = trainControl(method = "repeatedcv", 
                                                         number = 10, 
                                                         repeats = 15, 
                                                         savePredictions = TRUE, 
                                                         verboseIter = FALSE))
      
      
      uniformity_of_cell_size=input$Uniofcsize
      uniformity_of_cell_shape=input$Uofcellshape
      clump_thickness=input$Clumpthickness
      test=data.frame(uniformity_of_cell_size,uniformity_of_cell_shape,clump_thickness)
      test_data2=test_data[,1:4]
      results2 <- data.frame(actual = test_data2$classes,
                             predict(model_rf2, test, type = "prob"))
      
      results2$prediction <- ifelse(results2$benign > 0.5, "benign",
                                    ifelse(results2$malignant > 0.5, "malignant", NA))
      results2$prediction[1] 
    },
    colnames = FALSE
    )
    
output$feature <- renderPlot({
    # Displaying all the features in the data
  library(tidyr)
    library(dplyr)
    library(ggplot2)
    
    gather(bc_data, x, y, clump_thickness:mitosis) %>%
    ggplot(aes(x = y, color = classes, fill = classes)) +
    geom_density(alpha = 0.3) +
    facet_wrap( ~ x, scales = "free", ncol = 3)
    })
# Classification based on the neural network model
# nn model is build using the function neuralnet with hidden layer as c(2,1)
# classification based on labels: 1-Malignant, 0: Benign
output$classoutput <- renderTable({
    nn <- neuralnet(labels~marginal_adhesion+bare_nuclei+bland_chromatin,data=bc_data,hidden=c(2,1), linear.output=FALSE, threshold=0.01)
    
    test=data.frame(input$marginal_adhesion,input$bare_nuclei,input$bland_chromatin)
    Predict=compute(nn,test)
    # if the predicted probability is more than 0.5 it is malignant else it is benign tumor.
    Predict$net.result
    prob <- Predict$net.result
    pred <- ifelse(prob>0.5, 1, 0)
    print("Type of Tumor")
    if(pred==1)
      print("Malignant") 
    else
        print("Benign")
},colnames = FALSE
)
}

# Run the application 
shinyApp(ui = ui, server = server)
