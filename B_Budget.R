# Libraries and dir ----
x<-c("data.table", "dplyr", "xlsx", "tidyr", "lubridate")
lapply(x, require, character.only = TRUE)
setwd('C:/Users/Jarek/Desktop/Private/Budget')

# Files paths ----
a <- list.files(path = "C:/Users/Jarek/Desktop/Private/Budget")
for (el in 1:length(a)) {
  if (a[el] %like% "Feed_*") {
    feed_file = a[el]
  }
}
budget_file <- "C:/Users/Jarek/Desktop/Private/Budget/B_Budget.xlsx"

# Read data ----
feed_data <- read.csv2(feed_file, sep = ",", encoding = "UTF-8", stringsAsFactors = F)
colnames(feed_data)[1] <- 'date'
dict <- read.xlsx(file = budget_file, sheetName = "dict", encoding = "UTF-8", stringsAsFactors = F)
budget_2018 <- read.xlsx(file = budget_file, sheetName = "budget_2018",
                         encoding = "UTF-8", stringsAsFactors = F)
budget_2019 <- read.xlsx(file = budget_file, sheetName = "budget_2019_v1",
                         encoding = "UTF-8", stringsAsFactors = F)

# Transform data ----
spendee_data <- feed_data %>%
  select(date,
         wallet = Portfel,
         name = Nazwa.kategorii,
         amount = Kwota) %>%
  mutate(date = as.Date(date),
         amount = as.numeric(format(amount, decimal.mark = '.')))

bud18 <- gather(budget_2018, date, amount, X2018.01.01:X2018.12.01) %>%
  mutate(date = ymd(substr(date, 2, length(date))))
bud19 <- gather(budget_2019, date, amount, X2019.01.01:X2019.12.01) %>%
  mutate(date = ymd(substr(date, 2, length(date))))

# Join data and create output ----
spendee_data <- left_join(spendee_data, dict)
bud18 <- left_join(bud18, unique(dict[2:3]))
bud19 <- left_join(bud19, unique(dict[2:3]))

spendee_data$type <- 'Actual'
bud18$type <- 'Budget'
bud18$name <- NA
bud19$type <- 'Budget'
bud19$name <- NA

output <- rbind(spendee_data, bud18, bud19)

# Write to file ----
wb <- loadWorkbook(budget_file)
removeSheet(wb, sheetName = "output")
sheet1 <- createSheet(wb, sheetName = "output")
addDataFrame(output, sheet1, row.names = F)
saveWorkbook(wb, "C:/Users/Jarek/Desktop/Private/Budget/B_Budget.xlsx")