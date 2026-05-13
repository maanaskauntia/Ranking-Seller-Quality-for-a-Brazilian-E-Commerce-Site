WITH Economic_Value_And_Customer_Feedback AS
(
	SELECT i.seller_id, 
			COUNT(DISTINCT i.order_id) AS total_orders,
			round(SUM(i.price),2) as GMV, 
			round((round(SUM(i.price),2)/COUNT(DISTINCT i.order_id)),2) as AOV,
			-- Calculation of Distinct Active days in last 180 days (Recent Seller Activity)
			COUNT(DISTINCT CASE 
	        WHEN o.order_purchase_timestamp >= '2018-04-20' --last purchase on 17th Oct '18 
	        THEN DATE(o.order_purchase_timestamp) 
	    	END) AS active_days_in_180d,
	    	-- Calculating Average Customer Reviews for each seller
	    	round(AVG(r.review_score),2) AS avg_review_score
	FROM "SQL projects".main.olist_order_items_dataset AS i
		JOIN "SQL projects".main.olist_orders_dataset AS o ON i.order_id = o.order_id
		LEFT JOIN "SQL projects".main.olist_order_reviews_dataset AS r ON i.order_id = r.order_id
	GROUP BY i.seller_id 
	ORDER BY GMV desc
),

Economic_And_Customer_Metrics_Percentiles AS
(
	SELECT seller_id, total_orders,
			round(PERCENT_RANK() OVER (ORDER BY GMV),2) AS GMV_p,
			round(PERCENT_RANK() OVER (ORDER BY AOV),2) AS AOV_p,
			round(PERCENT_RANK() OVER (ORDER BY active_days_in_180d),2) AS recent_activity_p,
			round(PERCENT_RANK() OVER (ORDER BY avg_review_score),2) AS customer_reviews_p
	FROM Economic_Value_And_Customer_Feedback
),


Operational_Rigor_Percentile AS
(
    SELECT 
        i.seller_id,
        -- Calculating the Percentiles of Avg Carrier Handover Lag 
        round(PERCENT_RANK() OVER (ORDER by
								        AVG(
								            DATE_DIFF(
								                'hour',
								                CAST(NULLIF(o.order_delivered_carrier_date, '') AS TIMESTAMP),
								                CAST(NULLIF(i.shipping_limit_date, '') AS TIMESTAMP)
								            ) --negative hrs means delay
								        )),2) as shipping_reliability
    FROM "SQL projects".main.olist_order_items_dataset AS i
    JOIN "SQL projects".main.olist_orders_dataset AS o 
        ON i.order_id = o.order_id
    WHERE NULLIF(o.order_delivered_carrier_date, '') IS NOT NULL
    GROUP BY i.seller_id
),

Sellers_Scored AS
(
	SELECT ec.seller_id, ec.total_orders,
		    -- Weighted Average calculation
            (ec.GMV_p * 0.30 + ops.shipping_reliability * 0.25 + ec.customer_reviews_p * 0.20 + ec.recent_activity_p * 0.15 + AOV_p * 0.10) AS final_score
FROM Economic_And_Customer_Metrics_Percentiles AS ec 
JOIN Operational_Rigor_Percentile AS ops ON ec.seller_id=ops.seller_id
)

SELECT seller_id, total_orders,
	   round(final_score,2) AS final_score,
	    CASE 
	        WHEN total_orders >= 40 AND final_score >= 0.75 THEN 'Platinum'
	        WHEN total_orders >= 20 AND final_score >= 0.65 THEN 'Gold'
	        WHEN total_orders >= 5  AND final_score >= 0.40 THEN 'Silver'
	        ELSE 'Bronze'
	    END AS seller_tier
FROM Sellers_Scored
ORDER BY final_score DESC
