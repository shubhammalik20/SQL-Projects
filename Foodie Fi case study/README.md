![3](https://github.com/shubhammalik20/SQL-Projects/assets/135993334/bde7ad29-3731-41aa-93d3-9a3625dad292)

# Foodie Fi Case Study

Subscription based businesses are super popular and hence Foodie Fi is created that only had food related content - something like Netflix but with only cooking shows!

Foodie Fi started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world!

This case study focuses on using subscription style digital data to answer important business questions.
***

This case study consists of 2 tables:

- Plans

  Customers can choose which plans to join Foodie-Fi when they first sign up.

  Basic plan customers have limited access and can only stream their videos and is only available monthly at $9.90

  Pro plan customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual     subscription.

  Customers can sign up to an initial 7 day free trial will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.

  When customers cancel their Foodie-Fi service - they will have a churn plan record with a null price but their plan will continue until the end of the billing period.

- Subscriptions
  
  Customer subscriptions show the exact date where their specific plan_id starts.

  If customers downgrade from a pro plan or cancel their subscription - the higher plan will remain in place until the period is over - the start_date in the subscriptions table will reflect the date that the actual plan changes.

  When customers upgrade their account from a basic plan to a pro or annual pro plan - the higher plan will take effect straightaway.

  When customers churn - they will keep their access until the end of their current billing period but the start_date will be technically the day they decided to cancel their service.
  

    ![database schema ](https://github.com/shubhammalik20/SQL-Projects/assets/135993334/1bab8d96-9009-47c3-8c05-221fbaf95167)
***    
Questions Answered during analysis of the data using SQL

- How many customers has Foodie-Fi ever had?

- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?

- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

- What is the customer count and percentage of customers who have churned rounded to 1 decimal place??

- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

- What is the number and percentage of customer plans after their initial free trial?

- How many customers have upgraded to an annual plan in 2020?

- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
