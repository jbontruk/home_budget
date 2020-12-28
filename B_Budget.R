# Libraries ----
x <- c("data.table", "dplyr", "tidyr", "lubridate", "openxlsx")
lapply(x, require, character.only = TRUE)

# Directories ----
setwd('C:/Users/WealthArc/Downloads')
budget_file <- "Budżet_fix.xlsx"
feed_file_jarek <- 'transactions_export_2020-12-27_jarek.csv'
feed_file_ela <- 'transactions_export_2020-12-27_ela.csv'

# Get data ----
feed_data_jarek <- read.csv2(feed_file_jarek, sep = ",", encoding = "UTF-8", 
                             stringsAsFactors = F)
feed_data_ela <- read.csv2(feed_file_ela, sep = ",", encoding = "UTF-8",
                           stringsAsFactors = F)

dict <- read.xlsx(xlsxFile = budget_file, sheet = 'dict')

bud18 <- read.xlsx(xlsxFile = budget_file, sheet = 'budget_2018')
bud19 <- read.xlsx(xlsxFile = budget_file, sheet = 'budget_2019')
bud20 <- read.xlsx(xlsxFile = budget_file, sheet = 'budget_2020',
                         rows = c(1:23), cols = c(1:14))
bud21 <- read.xlsx(xlsxFile = budget_file, sheet = 'budget_2021',
                         rows = c(1:23), cols = c(1:14))

# Transform data ----
feed_data <- rbind(feed_data_jarek, feed_data_ela) %>%
  select(date = Date,
         wallet = Wallet,
         name = Category.name,
         amount = Amount) %>%
  mutate(date = as.Date(date),
         amount = as.numeric(format(amount, decimal.mark = '.')))

bud18 <- gather(bud18, date, amount, `2018-01-01`:`2018-12-01`) %>%
  mutate(date = ymd(date))
bud19 <- gather(bud19, date, amount, `2019-01-01`:`2019-12-01`) %>%
  mutate(date = ymd(date))
bud20 <- gather(bud20, date, amount, `2020-01-01`:`2020-12-01`) %>%
  mutate(date = ymd(date))
bud21 <- gather(bud21, date, amount, `2021-01-01`:`2021-12-01`) %>%
  mutate(date = ymd(date))

# Merge data ----
actual <- left_join(feed_data, dict[1:3])
bud18 <- left_join(bud18, unique(dict[2:3]))
bud19 <- left_join(bud19, unique(dict[2:3]))
bud20 <- left_join(bud20, unique(dict[2:3]))
bud21 <- left_join(bud21, unique(dict[2:3]))

actual$type <- 'Actual'
bud18$type <- 'Budget'
bud18$name <- NA
bud19$type <- 'Budget'
bud19$name <- NA
bud20$type <- 'Budget'
bud20$name <- NA
bud21$type <- 'Budget'
bud21$name <- NA

output <- rbind(actual, bud18, bud19, bud20, bud21)

# Write output ----
write.table(output, 'r_output.csv', row.names = F, sep = ',', dec = '.')