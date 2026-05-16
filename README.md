# Seller Segmentation Model for Olist (Brazilian E-Commerce Store)

### Project Overview: 

Olist is the largest E-Commerce store in Brazil that connects small businesses from all over the country to sales channels without hassle and with a single contract. The merchants are able to sell their products through the Olist Store and ship them directly to the customers using Olist’s logistics partners. See more on their website: www.olist.com

In 2018, the company released real commercial data on 100k+ orders made on their platform in the past 2 years. All personally identifiable information was anonymised. The dataset includes seller information, logistics details, and customer feedback on each order. Here’s the business problem this project solves:

> For any E-commerce store with national presence, customer support is an expensive operation. It is well known for companies with a huge market share that a very small percentage of sellers bring in a disproportionately high percentage of revenue. Thus, it makes sense to segment the sellers based on the value they bring in, and provide equivalent levels of customer service to them.

> The project fills this gap with a model that divides ~3000 sellers on the Olist platform into 4 segments: Platinum, Gold, Silver and Bronze. The segmentation is based on the economic value delivered by each seller, their popularity among customers, and their operational rigor in shipping products. Having taken these dimensions together, we find that the top 12% of sellers contribute to 55% of the Gross Merchandise Value on Olist’s platform. 

Based on this data, recommendations are made on the level of customer service that can be provided to each seller segment (with Platinum receiving the most premium support and Bronze support being transitioned into an end-to-end AI automated workflow). 

The SQL script utilized to achieve the insights can be found here.

-----------------------------

### Data Structure and Description: 

The company released a relational database with 8 tables. From them, the project utilised the highlighted tables:

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/19GONR_mHtv3jc6GU8AOLZHtflf0YP10g" alt="Seller Segments" width="800">
</div>

1) olist_orders_dataset: This is the core dataset of the table. It has order_id, which is the primary key used to join data from both the olist_order_reviews_dataset and the olist_order_items_dataset.

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/1f43VQcgf8UQpFTZlOefekSRHL5iyd1L6" alt="Seller Segments" width="800">
</div>

2) olist_order_reviews_dataset: This dataset contains reviews made by customers on each order. It has the review_score, where a customer rates their experience on a scale of 1 to 5.

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/1ga3-0-VGcuq8Ezl-NwOWl2zd1YZgoxzB" alt="Seller Segments" width="800">
</div>

3) olist_order_items_dataset: This dataset includes data on the items purchased within each order. Most importantly, it has the shipping_limit_date, which is the deadline for a seller to hand over their products to Olist’s logistics partners. Every order has this auto-generated deadline attached to it for each seller.

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/1Im5uthF7cHPi4ZCX6fvD_80Gr8_U9EiO" alt="Seller Segments" width="800">
</div>

These are all the tables that were joined and utilized to build the segmentation model.

-------------------------

### Building the Segmentation Model:

In order to create the seller tiering, the following process was followed:

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/1G9siNwuhYp5aaaJ3E2DGP3vaCx7tvkoG" alt="Seller Segments" width="900">
</div>

We assess seller performance on three grounds:

Economic Value 
Customer Feedback 
Operational Rigor 

All of these have metrics attached to them, which were calculated from the data available.

Economic Value-

Gross Merchandise Value (GMV): This metric captures the total price of all goods sold by a single seller. We get to know exactly how much business the seller does with us, thus differentiating the market whales from the smaller folks.

Average Order Value (AOV): This captures the average value of an order being supplied by a seller. A seller supplying one iPhone 13 provides more business than another selling 5 budget-friendly sneakers.

Recent Seller Activity (active_days_in_180d): This metric captures, “In the last 6 months (180 days), how many days did you actually make a sale on our platform?” High-value sellers who have become dormant are less important than mid-value sellers converting sales daily.

Customer Feedback- This pillar has a single metric- avg_review_score, which captures the average customer feedback on a five-point scale. We get an understanding of the credibility of each seller, and their popularity among customers.

Operational Rigor- Even here, we utilize a single metric- shipping_reliability. This metric captures whether a seller hands their packages over to the logistics carrier on time. It has been measured in hours, where positive hours means before time and negative hours means delayed operations.

In total, these are the 5 metrics that exist across the pillars- GMV, AOV, active_days_in_180d, avg_review_score, shipping_reliability. Once they are calculated from data available in the 3 datasets, the next challenge is aggregation. Here, the question is- “How do you come up with one score that gives you a holistic view of seller quality? How do you aggregate average order value, for instance, with customer feedback?” It is to this question we turn next.

Aggregating The Metrics, Finalizing the Tiers

It does not make sense to sum up dollars, hours, customer reviews, activity and make the highest scorer a Platinum Seller. These metrics differ in what the numbers behind them truly mean. However, there is a way in which all metrics can be combined to give a final_score for each seller.


We can give all sellers ‘percentile ranks’ for each metric. A seller can thus be in the 99th percentile on GMV (which means they are among the top 1% money-makers), and can be in the 85th percentile on avg_review_score (among the top 15% in popularity among consumers). The interesting thing about percentile ranks is that they can be summed up for all metrics. However, simple summing up would still give equal weight to each metric. Here’s where the second step comes in.

Depending on the business philosophy of our e-commerce company, we can give more importance to some metrics than others. This can be achieved through weighted averages, where we can literally decide, “30% weight goes to GMV (most important metric), 25% to shipping_reliability, 20% to avg_review_score, 15% to active_days_in_180d and 10% to AOV”. This is exactly how the script achieves the final_score for each seller.

Finally, we would also want to add some volume caveats to ensure outliers don’t ruin our segmentation. For instance, we would want only sellers who have maintained the above performance across 40+ orders to be categorised in the Platinum segment.

Thus, with the final_score and the total_orders caveats in place, we achieve a robust segmentation model.

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/1ut7DD6BzEn56-2zmiLbs-_Rc5J9v-8RC" alt="Left Segment Image" width="48%">
  <img src="https://lh3.googleusercontent.com/d/1swUbWC0Exp10DOFFFbf_a0pcqYBxxYiA" alt="Right Segment Image" width="48%">
</div>

Here’s the result our query achieves: 

<div align="center">
  <img src="https://lh3.googleusercontent.com/d/1HiYXGg_78CLleSrLdTNz8u6lHer0EBux" alt="Seller Segments" width="600">
</div>

Based on this segmentation, we can now make recommendations on the level of customer service that could be provided to sellers within each tier, while keeping our costs minimal.

--------------------------------

### Segment-Specific Insights and Recommendations:

In order to make recommendations, it is important to have a deep understanding of the seller-profile in each segment. Simply put, we’d want to know how an average seller in a segment performs across metrics, what their weaknesses are, and consequently, what their needs might be.

<div align="center">
  <img src="https://drive.google.com/file/d/1QXo4tjCJHUjv-ASn54V1Y63MuIipy328/view?usp=sharing" alt="Seller Segments" width="600">
</div>

Here is the script that returns the seller profiles shown above.

Platinum (the 2% responsible for 16% business*): Platinum sellers have the highest level of performance across metrics. Most importantly, these are 67 merchants (i.e., only 2% of the ~3000 sellers on the platform) responsible for 16% of the merchandise value listed on Olist. Thus, these sellers should be provisioned with the highest quality of services to prevent them from switching e-commerce platforms. Here are recommended services:

Provide 1 dedicated Account Manager to each Platinum seller who is the first Point of Contact for any issues with the Product. These managers will help coordinate actions between the seller and the internal customer support team, escalating issues whenever needed.
Achieve fastest ticket closing times for all Platinum sellers (with a target of <24 hrs on one ticket). We have to deliver on the speed as with the highest ROI stakes, every minute counts.
Set up a team of the most experienced and tenured customer support agents to handle Platinum tickets (which will surely be of the highest complexity considering the scale and time).
Process refunds with least questions asked to sustain seller trust.
Reduce estimated delivery times shown to customers by at least 4 days. This is because, as we can see in the table above, Platinum customers handover the goods to the logistics carrier nearly 120 hrs (5 days) before the decided time. We have a strong opportunity to reduce the decided time, which then reduces the estimated delivery time to customers. This leads to both increased customer satisfaction and a higher purchase rate (as customers purchase more when the estimated delivery is quicker).


*Here, merch value is taken as a key economic indicator for business value since exact revenue data was unavailable

Gold (the 10% responsible for 40% business): Gold sellers are 286 merchants (~10% of ~3000 sellers on the platform) responsible for 40% of the merchandise value listed on Olist. These are also incredibly high value clients, with consistently high performance across metrics. To ensure we secure our business with these clients, the following services are recommended for them (the idea being, quality of service should only be second to Platinum):

Provide 1 dedicated Account Manager to each Gold seller. The key difference here would be that on Olist’s end, we can have an Account Manager handling 10 Gold accounts while another more experienced manager can handle 5 Platinum Accounts.
Achieve fast ticket closing times for Gold sellers (with a target of <48 hrs on one ticket). Again, revenue stakes per minute might not be as high as Platinum, but is still incredibly high.
Set up a team of expert customer support agents with experience comparable to Platinum agents.
Reduce estimated delivery times to customers by at least 3 days. This is because Gold customers handover the goods to the logistics carrier nearly 96 hrs (4 days) before the decided time, as we see in the above table. 

Before we move on to the Silver and Bronze tier recommendations, it is important to recognise that having this customer support structure in place guarantees that 55% of our business is secure, by providing premium customer support to only the top 12% of our sellers. 

Silver (the 40% responsible for 40% business): These are ~1200 sellers responsible for 40% of the merchandise value listed on our platform. This is still a huge chunk of the business, but the number of clients is also quite high. Thus, dedicated personal support (with Account Managers and expert support agents) is not a cost efficient path. We can still provide quality service delivery while keeping costs low by:

Adopting an AI + Human service model. Here, the customer first interacts with an AI chatbot, and only if they are dissatisfied, they get the option of contacting a generalist customer support agent. These agents in the Silver tier are early-career troubleshooting talent who have been trained on a host of issues focusing on breadth of the product. If they cannot handle a case, it can be escalated to an internal team of experts dedicated solely for doubt-resolution in the Silver segment.
Keeping the timeliness targets moderate (say, resolution in <72 hrs). To make a process faster is often costlier, and the ROI for that in the Silver tier is currently not significant.
Establishing faster delivery times by 2 days. This is a low hanging fruit here as well. It won’t cost us anything to decrease the estimated delivery times because we are getting the goods from the sellers 3 days before promised.

Bronze (the 50% responsible for 5% business): These are the ~1500 sellers who bring negligible merch to the platform. Considering the miniscule business value (5%), customer service for them can be entirely automated end-to-end. However, it is interesting to note that the Average Order Value for these sellers is higher than for the sellers in Gold and Silver (204 vs <190). This means that it is exclusively a volume issue, which is an interesting problem to be worked upon by the sales team (as it does not fall under the purview of customer support). 




