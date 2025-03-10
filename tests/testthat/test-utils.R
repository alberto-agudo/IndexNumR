context("utilities")

continuous1 <- c(1,2,3,4,5,6)
continuous2 <- c(1,1,1,2,2,2,3,3,4,5,5,5)
gaps1 <- c(1,2,4,5,6)
gaps2 <- c(1,1,1,2,2,4,5,5,5)
gaps3 <- c(1,1,1,2,2,2,5,5,5)

test_that("gaps in a vector are detected",{
  expect_equal(isContinuous(continuous1),list(result=TRUE))
  expect_equal(isContinuous(continuous2),list(result=TRUE))
  expect_equal(isContinuous(gaps1),list(result=FALSE,missing=3))
  expect_equal(isContinuous(gaps2),list(result=FALSE,missing=3))
  expect_equal(isContinuous(gaps3),list(result=FALSE,
                                        missing=as.integer(c(3,4))))
})


test_that("checkTypes converts factor columns to numeric", {

  testData <- CES_sigma_2
  testData$time <- as.factor(testData$time)

  testData <- checkTypes(testData, pervar = "time", pvar = "prices", qvar = "quantities")

  expect_equal(inherits(testData$time, "numeric"), TRUE)

})


test_that("KennedyBeta calculates the correct adjustment", {

  dat <- CES_sigma_2[CES_sigma_2$time <= 2,]
  dat$prodID <- as.factor(dat$prodID)
  dat$D <- ifelse(dat$time == 2, 1, 0)

  reg <- lm(prices ~ D + prodID, data = dat)

  expect_equal(kennedyBeta(reg), c(`(Intercept)` = 1.95953776,
                                   D = -0.194869792,
                                   prodID2 = -1.139739583,
                                   prodID3 = -0.914739583,
                                   prodID4 = -1.364739583))

})


test_that("checkTypes can detect bad variable types", {

  bad <- letters[1:5]
  good <- 1:5

  df <- data.frame(p = bad, q = good, period = good, prodID = LETTERS[1:5])

  expect_error(expect_warning(checkTypes(df, "p", "q", "period")),
               "Please correct input data types. Price variable is not numeric and cannot be coerced to numeric")

  df <- data.frame(p = good, q = bad, period = good, prodID = LETTERS[1:5])

  expect_error(expect_warning(checkTypes(df, "p", "q", "period")),
               "Please correct input data types. Quantity variable is not numeric and cannot be coerced to numeric")

  df <- data.frame(p = good, q = good, period = bad, prodID = LETTERS[1:5])

  expect_error(expect_warning(checkTypes(df, "p", "q", "period")),
               "Please correct input data types. Time period variable is not numeric and cannot be coerced to numeric")


})


test_that("windowMatch removes products correctly", {

  # remove product 1 from last few periods and product 3 from first few periods
  df <- CES_sigma_2[-c(8:12, 25:26),]

  # window matching should only return products 2 and 4
  wmdf <- windowMatch(df, "time", "prodID")

  expect_equal(wmdf, CES_sigma_2[CES_sigma_2$prodID %in% c(2, 4),])

})
