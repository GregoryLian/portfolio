-- 1
DESCRIBE passengers_on_flights;

ALTER TABLE passengers_on_flights ADD CONSTRAINT FOREIGN KEY(route_id) REFERENCES routes(route_id);
ALTER TABLE passengers_on_flights ADD CONSTRAINT FOREIGN KEY(customer_id) REFERENCES customer(customer_id);

-- 2
CREATE TABLE IF NOT EXISTS route_details (
route_id INT NOT NULL,
flight_num INT NOT NULL CHECK(flight_num <> 0),
origin_airport TEXT NOT NULL,
destination_airport TEXT NOT NULL,
aircraft_id TEXT NOT NULL,
distance_miles INT NOT NULL CHECK(distance_miles > 0),
FOREIGN KEY(route_id) REFERENCES routes(route_id),
UNIQUE(route_id)
);

SELECT * FROM route_details;
DESCRIBE route_details;

-- 3
SELECT * FROM customer C
	INNER JOIN passengers_on_flights P
		ON C.customer_id = P.customer_id
			WHERE P.route_id BETWEEN 1 AND 25
				ORDER BY P.route_id
;
	
-- 4
SELECT sum(no_of_tickets) AS `number of passengers`, sum(Price_per_ticket*no_of_tickets) AS `total revenue in business class` FROM ticket
	WHERE class_id = 'Bussiness'
;

-- 5
SELECT concat(first_name, ' ',last_name) FROM customer;

-- 6
SELECT distinct(T.customer_id), C.* FROM customer C
	INNER JOIN ticket T
		ON C.customer_id = T.customer_id
			WHERE T.no_of_tickets > 0 
				ORDER BY C.customer_id
;

-- 7
SELECT T.customer_id, C.first_name, C.last_name FROM ticket T
	LEFT JOIN customer C
		ON T.customer_id = C.customer_id
			WHERE T.brand = 'Emirates'
;

-- 8
SELECT * FROM passengers_on_flights P
	LEFT JOIN customer C
		ON P.customer_id = C.customer_id
			GROUP BY P.customer_id
				HAVING P.class_id = 'Economy Plus'
;

-- 9
SELECT if(sum(no_of_tickets*price_per_ticket) > 10000, 'Yes', 'No') AS `Did revenue cross $10,000?` FROM ticket
;

-- 10
CREATE VIEW business_class_brand AS
	SELECT C.*, T.brand FROM ticket T
		LEFT JOIN customer C
			ON T.customer_id = C.customer_id
				WHERE T.class_id = 'Bussiness'
;

-- 11 my answer that isn't correct
DELIMITER &&
CREATE PROCEDURE passenger_details_for_route(IN route_taken INT)
BEGIN
SELECT C.*, if(route_taken IN (P.route_id), 'Flying', 'Error') AS `Status` FROM passengers_on_flights P
	LEFT JOIN customer C 
		ON P.customer_id = C.customer_id
			WHERE P.route_id = route_taken;
END &&
DELIMITER ;

CALL passenger_details_for_route(2);
SELECT * FROM passengers_on_flights;

SELECT * FROM passengers_on_flights P
	LEFT JOIN customer C 
		ON P.customer_id = C.customer_id
			WHERE P.route_id = route_taken
            ;

-- 11 answer from others
DELIMITER &&
CREATE PROCEDURE get_p_details_from_routeids(IN starting_routeid INT, IN ending_routeid INT)
BEGIN
	IF EXISTS (SELECT route_id FROM passengers_on_flights  
					WHERE route_id BETWEEN starting_routeid AND ending_routeid)
		THEN (SELECT P.*, C.customer_id, C.first_name, C.last_name, C.date_of_birth, C.gender FROM passengers_on_flights P
					LEFT JOIN customer C
						ON P.customer_id = C.customer_id
							WHERE P.route_id BETWEEN starting_routeid AND ending_routeid
			);
		ELSE
			SELECT 'Error: No rows found or table does not exist!' AS Message;
	END IF;
END &&
DELIMITER ;

CALL get_p_details_from_routeids(43,1100);

-- 11 right answer should be to do error handler
DELIMITER &&
CREATE PROCEDURE get_p_details(IN starting_routeid INT, IN ending_routeid INT)
BEGIN
	DECLARE EXIT HANDLER FOR 1146 SELECT 'Kindly check the table name in procedure definition';
		SELECT * FROM passengers_on_routes
			WHERE route_id BETWEEN starting_routeid AND ending_routeid;
END &&
DELIMITER ;

CALL get_p_details(60,100);

-- 12
DELIMITER &&
CREATE PROCEDURE route_more_than_2000miles()
BEGIN
SELECT * FROM routes
	WHERE distance_miles > 2000; 
END &&
DELIMITER ;

CALL route_more_than_2000miles();

-- 13
DELIMITER &&
CREATE PROCEDURE get_categories_by_distance()
BEGIN
SELECT *, 
CASE	 
	WHEN R.distance_miles <= 2000 THEN 'SDT'
    WHEN R.distance_miles > 6500 THEN 'LDT'
    ELSE 'IDT'
END AS `Category` FROM routes R
		ORDER BY R.distance_miles ;
END &&
DELIMITER ;

CALL get_categories_by_distance();



SELECT R.flight_num, 
CASE	 
	WHEN R.distance_miles > 6500 THEN 'LDT'
    WHEN R.distance_miles > 2000 THEN 'IDT'
    ELSE 'SDT'
END AS `Category` FROM routes R
		WHERE R.flight_num = 1111;

























