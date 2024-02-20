--TASK 1--
/*1.*/ CREATE DATABASE LOANS

/*2.*/ SELECT NAME FROM SYS.DATABASES


/*3.*/ use Loans
       select TABLE_NAME
       from INFORMATION_SCHEMA.tables
       where table_type = 'base table'

/*4.*/  SELECT TOP 5* FROM Banker_Data
        SELECT TOP 5* FROM Customer_Data
        SELECT TOP 5* FROM Home_Loan_Data 
        SELECT TOP 5* FROM Loan_Records_Data

--TASK 2--

--Q.  --Find the average age of male bankers (years, rounded to 1 decimal place) based on the date they joined WBG--

--ANS.
    SELECT AVG(AVG_AGE) AS AVG_AGE FROM (
     SELECT CONVERT (FLOAT,(DATEDIFF(YEAR,DOB,DATE_JOINED))) AS AVG_AGE FROM BANKER_DATA
	 WHERE GENDER = 'MALE') AS M

--Q. -- Find the number of home loans issued in San Francisco.--

--ANS.
      SELECT COUNT(*) AS NUMBER_OF_LOANS FROM Home_Loan_Data
      WHERE CITY = 'SAN FRANCISCO'

--Q. --Find the city name and the corresponding average property value (using appropriate alias) for cities where the average property value is greater than $3,000,000.--

--ANS.
     SELECT CITY,AVG(PROPERTY_VALUE) AS AVERAGE_PROPERTY_VALUE 
     FROM Home_Loan_Data
     GROUP BY city
     HAVING AVG(PROPERTY_VALUE)> 3000000

--Q. --Find the maximum property value (using appropriate alias) of each property type, ordered by the maximum property value in descending order. --

--ANS.
     SELECT PROPERTY_TYPE, MAX(PROPERTY_VALUE) AS MAX_PROPERTY_VALUE 
	 FROM HOME_LOAN_DATA
	 GROUP BY PROPERTY_TYPE
	 ORDER BY MAX_PROPERTY_VALUE DESC

--Q. --Find the total number of different cities for which home loans have been issued.  --

--ANS.
     SELECT COUNT(DISTINCT CITY) AS TOTAL_CITIES
     FROM Home_Loan_Data

--Q. --Find the names of the top 3 cities (based on descending alphabetical order) and corresponding loan percent (in ascending order) with the lowest average loan percent.--

--ANS.
     SELECT TOP 3 CITY, AVG(LOAN_PERCENT) AS AVERAGE_LOAN_PERCENT
	 FROM Home_Loan_Data
	 GROUP BY city
	 ORDER BY AVERAGE_LOAN_PERCENT ASC, CITY DESC 

--Q. --Find the ID, first name, and last name of the top 2 bankers (and corresponding transaction count) involved in the highest number of distinct loan records. --

--ANS.
   SELECT TOP 2 bd.banker_id, bd.first_name, bd.last_name, COUNT(DISTINCT lrd.loan_id) AS transaction_count
    FROM loan_records_data lrd
    Inner JOIN banker_data bd ON lrd.banker_id = bd.banker_id
    GROUP BY bd.banker_id, bd.first_name, bd.last_name
    ORDER BY transaction_count DESC

--Q. --Find the customer ID, first name, last name, and email of customers whose email address contains the term 'amazon'.--

--ANS.
    SELECT CUSTOMER_ID, FIRST_NAME, LAST_NAME,EMAIL 
	FROM CUSTOMER_DATA
	WHERE EMAIL LIKE'%AMAZON%'

--Q. --Find the average loan term for loans not for semi-detached and townhome property types, and are in the following list of cities: Sparks, Biloxi, Waco, Las Vegas, and Lansing.

--ANS.
     SELECT AVG(loan_term) AS average_loan_term
     FROM HOME_loan_data
     WHERE property_type NOT IN ('semi-detached', 'townhome')
     AND city IN ('Sparks', 'Biloxi', 'Waco', 'Las Vegas', 'Lansing')

--Q. --Find the average age (at the point of loan transaction, in years and nearest integer) of female customers who took a non-joint loan for townhomes.--

--ANS.
     SELECT AVG(DATEDIFF(YEAR,DOB,TRANSACTION_DATE)) AS AVG_AGE FROM CUSTOMER_DATA AS A
     INNER JOIN LOAN_RECORDS_DATA AS B
	 ON A.CUSTOMER_ID = B.CUSTOMER_ID
	 INNER JOIN HOME_LOAN_DATA AS C
	 ON B.LOAN_ID = C.LOAN_ID
	 WHERE GENDER = 'FEMALE'
	 AND PROPERTY_TYPE LIKE 'TOWN%'
	 AND JOINT_LOAN = 'NO'


--TASK 3--

--Q. --Create a view called dallas_townhomes_gte_1m which returns all the details of loans involving properties of townhome type, located in Dallas, and have loan amount of >$1 million.--


CREATE VIEW dallas_townhomes_gte_1m AS
SELECT *
FROM home_loan_data
WHERE property_type = 'townhome'
AND city = 'Dallas'
AND property_value > 1000000

select * from dallas_townhomes_gte_1m

--Q. --Find the ID, first name and last name of customers with properties of value between $1.5 and $1.9 million, along with a new column 'tenure' that categorizes how long the customer has been with WBG.-- 

--The 'tenure' column is based on the following logic:
--Long: Joined before 1 Jan 2015
--Mid: Joined on or after 1 Jan 2015, but before 1 Jan 2019
--Short: Joined on or after 1 Jan 2019

--ANS. 
       select c.customer_id as ID,c.first_name,c.last_name,property_value,--date_joined,
	case
		when date_joined < '2015-01-01' then 'Long' 
		when date_joined >= '2015-01-01' and date_joined < '2019-01-01' then 'Mid'
		when date_joined >= '2019-01-01' then 'Short'
		else 'nothing'
	end as Tennure
from Customer_Data C 
inner join Loan_Records_Data L on C.customer_id = L.customer_id
left  join Home_Loan_Data H on  H.loan_id  = L.loan_id
left join Banker_Data b on B.banker_id = L.banker_id
where property_value between 1500000 and 1900000

--Q. --Find the top 3 transaction dates (and corresponding loan amount sum) for which the sum of loan amount issued on that date is the highest. 

--ANS.
select top 3 transaction_date,sum((property_value*loan_percent)/100) loan_amount from Banker_Data B 
inner join Loan_Records_Data L on b.banker_id = L.banker_id
inner join Home_Loan_Data H on h.loan_id = L.loan_id 
group by transaction_date
order by transaction_date desc



--Q. --Find the ID and full name (first name concatenated with last name) of customers who were served by bankers aged below 30 (as of 1 Aug 2022).  (3 Marks)

--ANS.
SELECT C.customer_id AS ID,
       CONCAT(C.first_name, ' ', C.last_name) AS Full_Name
FROM Customer_Data AS C
JOIN Loan_Records_Data AS L ON C.customer_id = L.customer_id
JOIN Banker_Data AS B ON L.banker_id = B.banker_id
WHERE DATEDIFF(YEAR, B.dob, '2022-08-01') < 30

--Q. --Find the number of Chinese customers with joint loans with property values less than $2.1 million, and served by female bankers

--ANS. 
select count(*) chinese_customer from Customer_Data C
inner join Loan_Records_Data L on C.customer_id =l.customer_id
inner join Banker_Data B on B.banker_id = l.banker_id
inner join Home_Loan_Data h on h.loan_id = l.loan_id
where nationality = 'China' and joint_loan = 'yes' and property_value <2100000
and b.gender = 'female'

--Q. --Find the number of bankers involved in loans where the loan amount is greater than the average loan amount.

--ANS.
Select count(*) total_bankers from Banker_Data b
inner join Loan_Records_Data l on l.banker_id = b.banker_id
inner join Home_Loan_Data h  on h.loan_id = l.loan_id
where property_value > (select avg(property_value) from Home_Loan_Data)



--Q. -- Find the sum of the loan amounts ((i.e., property value x loan percent / 100) for each banker ID, excluding properties based in the cities of Dallas and Waco. 
--The sum values should be rounded to nearest integer.

--ANS.
SELECT C.banker_id ,SUM((property_value*loan_percent)/100) AS LOAN_SUM FROM Home_Loan_Data AS A
INNER JOIN Loan_Records_Data AS B 
ON A.loan_id=B.loan_id
INNER JOIN Banker_Data AS C 
ON B.banker_id=C.banker_id 
WHERE city NOT IN ( 'DALLAS', 'WACO')
GROUP BY C.banker_id



--Q. --Create a stored procedure called recent_joiners that returns the ID, concatenated full name, date of birth, and join date of bankers who joined within the recent 2 years (as of 1 Sep 2022) 
    --Call the stored procedure recent_joiners you created above


CREATE PROCEDURE recent_joiners 
AS 
BEGIN  
      SELECT banker_id,concat(first_name,' ',last_name) as full_name,dob,date_joined FROM Banker_Data
	  where date_joined between dateadd(YEAR,-2,'2022-09-01') AND '2022-09-01'

END
 

 EXEC recent_joiners


 /*Q.Create a stored procedure called city_and_above_loan_amt that takes in two parameters (city_name, loan_amt_cutoff) that returns the full details of customers with loans for properties in the input city and with loan amount greater than or equal to the input loan amount cutoff.  
--Call the stored procedure city_and_above_loan_amt you created above, based on the city San Francisco and loan amount cutoff of $1.5 million*/



    CREATE PROCEDURE city_and_above_loan_amt 
    @city_name NVARCHAR(255),
    @loan_amt_cutoff DECIMAL(18, 2)
AS
BEGIN
    SET NOCOUNT ON

    SELECT *
    FROM Home_Loan_Data
    WHERE city = @city_name
    AND property_value>= @loan_amt_cutoff
END

EXEC city_and_above_loan_amt 'San Francisco', 1500000