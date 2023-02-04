# Libraries ----
x <- c("data.table", "dplyr", "tidyr", "lubridate", "openxlsx")
lapply(x, require, character.only = TRUE)

# Directories ----
setwd('C:/Users/Bontruk/Downloads')
budget_file <- "Budżet.xlsx"
feed_file_jarek <- 'transactions_export_2023-02-01_jarek.csv'
feed_file_ela <- 'transactions_export_2023-02-01_ela.csv'

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
bud22 <- read.xlsx(xlsxFile = budget_file, sheet = 'budget_2022',
                   rows = c(1:23), cols = c(1:14))
bud23 <- read.xlsx(xlsxFile = budget_file, sheet = 'budget_2023',
                   rows = c(1:24), cols = c(1:14))

# Transform data ----
feed_data <- rbind(feed_data_jarek, feed_data_ela) %>%
  select(date = Date,
         wallet = Wallet,
         name = Category.name,
         amount = Amount,
         Note, Labels) %>%
  mutate(date = as.Date(date),
         amount = as.numeric(format(amount, decimal.mark = '.')))

bud18 <- gather(bud18, date, amount, `2018-01-01`:`2018-12-01`)
bud19 <- gather(bud19, date, amount, `2019-01-01`:`2019-12-01`)
bud20 <- gather(bud20, date, amount, `2020-01-01`:`2020-12-01`)
bud21 <- gather(bud21, date, amount, `2021-01-01`:`2021-12-01`)
bud22 <- gather(bud22, date, amount, `2022-01-01`:`2022-12-01`)
bud23 <- gather(bud23, date, amount, `2023-01-01`:`2023-12-01`)

bud <- rbind(bud18, bud19, bud20, bud21, bud22, bud23) %>%
  mutate(date = ymd(date))

# Merge data ----
actual <- left_join(feed_data, dict[1:3])
actual$type <- 'Actual'

bud <- left_join(bud, unique(dict[2:3]))
bud$type <- 'Budget'
bud$name <- NA
bud$Note <- NA
bud$Labels <- NA

output <- rbind(actual, bud)

# Write output ----
write.table(output, 'r_output.csv', row.names = F, sep = ',', dec = '.')
