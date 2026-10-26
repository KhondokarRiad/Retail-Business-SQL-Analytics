# Dataset

This project uses the **Maven Market retail dataset**, which contains data related to customers, products, stores, regions, transactions, returns, and calendar dates.

The raw CSV files used in this project are included in this folder for reproducibility and easier project review.

## Files Included

- `MavenMarket_Customers.csv`
- `MavenMarket_Products.csv`
- `MavenMarket_Stores.csv`
- `MavenMarket_Regions.csv`
- `MavenMarket_Returns_1997-1998.csv`
- `MavenMarket_Transactions_1997.csv`
- `MavenMarket_Transactions_1998.csv`
- `MavenMarket_Calendar.csv`

## Dataset Structure

The dataset follows a relational structure:

- **Customers** contains customer information.
- **Products** contains product, brand, retail price, and cost information.
- **Stores** contains store-level details.
- **Regions** contains regional information associated with stores.
- **Transactions** contains retail sales activity for 1997 and 1998.
- **Returns** contains product return activity.
- **Calendar** provides date-related information for time-based analysis.

For the SQL analysis, the 1997 and 1998 transaction files were imported into PostgreSQL and combined into a single `transactions` table.

## Use in This Project

The dataset was analyzed using **PostgreSQL** to evaluate:

- Revenue and gross profit
- Customer activity and segmentation
- Product and brand performance
- Store performance
- Regional revenue contribution
- Monthly revenue trends
- Month-over-month growth
- Advanced rankings and window functions
- Product and store return behavior

## Notes

The dataset does not contain a unique invoice or order identifier. As a result, true order-level metrics such as Average Order Value were not calculated.

Customer repeat activity in this project is therefore treated as a transaction-record-based proxy rather than a confirmed repeat-order metric.

Return value calculations are analytical estimates based on returned quantity and product retail price and should not be interpreted as confirmed lost revenue.
