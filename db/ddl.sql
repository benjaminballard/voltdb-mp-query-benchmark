 -- This file is part of VoltDB.
 -- Copyright (C) 2008-2013 VoltDB Inc.

 -- This program is free software: you can redistribute it and/or modify
 -- it under the terms of the GNU Affero General Public License as
 -- published by the Free Software Foundation, either version 3 of the
 -- License, or (at your option) any later version.

 -- This program is distributed in the hope that it will be useful,
 -- but WITHOUT ANY WARRANTY; without even the implied warranty of
 -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 -- GNU Affero General Public License for more details.

 -- You should have received a copy of the GNU Affero General Public License
 -- along with VoltDB.  If not, see <http://www.gnu.org/licenses/>.


-------------------- EXAMPLE SQL -----------------------------------------------
-- CREATE TABLE example_of_types (
--   id              INTEGER NOT NULL, -- java int, 4-byte signed integer, -2,147,483,647 to 2,147,483,647
--   name            VARCHAR(40),      -- java String
--   data            VARBINARY(256),   -- java byte array 
--   status          TINYINT,          -- java byte, 1-byte signed integer, -127 to 127
--   type            SMALLINT,         -- java short, 2-byte signed integer, -32,767 to 32,767
--   pan             BIGINT,           -- java long, 8-byte signed integer, -9,223,372,036,854,775,807 to 9,223,372,036,854,775,807
--   balance_open    FLOAT,            -- java double, 8-byte numeric
--   balance         DECIMAL,          -- java BigDecimal, 16-byte fixed scale of 12 and precision of 38
--   last_updated    TIMESTAMP,        -- java long, org.voltdb.types.TimestampType, 8-byte signed integer (milliseconds since epoch)
--   CONSTRAINT pk_example_of_types PRIMARY KEY (id)
-- );
-- PARTITION TABLE example_of_types ON COLUMN id;
--
-- CREATE VIEW view_example AS 
--  SELECT type, COUNT(*) AS records, SUM(balance)
--  FROM example_of_types
--  GROUP BY type;
-- 
-- CREATE PROCEDURE FROM CLASS procedures.UpsertSymbol;
-- PARTITION PROCEDURE UpsertSymbol ON TABLE symbols COLUMN symbol PARAMETER 0;
---------------------------------------------------------------------------------

-------------- REPLICATED TABLES ------------------------------------------------

CREATE TABLE inventory (
  inventory_id           INTEGER        NOT NULL,
  site_id                INTEGER       NOT NULL,
  page_id                INTEGER       NOT NULL,
  CONSTRAINT pk_inventory PRIMARY KEY (inventory_id)
);

CREATE TABLE creatives (
  creative_id            INTEGER       NOT NULL,
  campaign_id            INTEGER       NOT NULL,
  advertiser_id          INTEGER       NOT NULL,
  CONSTRAINT pk_creatives PRIMARY KEY (creative_id)
);

-------------- PARTITIONED TABLES ----------------------------------------------

CREATE TABLE event_data (
  utc_time               TIMESTAMP     NOT NULL,
  ip_address             BIGINT        NOT NULL,
  cookie_uid             BIGINT,
  creative_id            INTEGER       NOT NULL,
  inventory_id           INTEGER       NOT NULL,
  type_id                INTEGER       NOT NULL,
  cost                   DECIMAL,
  -- derived from creative_id:
  campaign_id            INTEGER       NOT NULL,
  advertiser_id          INTEGER       NOT NULL,
  -- derived from inventory_id:
  site_id                INTEGER       NOT NULL,
  page_id                INTEGER       NOT NULL,
  -- derived from type_id:
  is_impression          INTEGER       NOT NULL,
  is_clickthrough        INTEGER       NOT NULL,
  is_conversion          INTEGER       NOT NULL
);
PARTITION TABLE event_data ON COLUMN creative_id;

-------------- VIEWS ----------------------------------------------

CREATE VIEW campaign_rates AS
SELECT 
  advertiser_id, 
  campaign_id, 
  COUNT(*) AS records, 
  SUM(is_impression) AS impressions, 
  SUM(is_clickthrough) AS clicks, 
  SUM(is_conversion) as conversions,
  SUM(cost) as cost
FROM event_data
GROUP BY advertiser_id, campaign_id;

CREATE PROCEDURE advertiser_summary AS
SELECT 
  campaign_id,
  cost as spent,
  impressions,
  1000*cost/impressions as cpm,
  clicks,
  CAST(clicks AS DECIMAL)/impressions AS ctr, 
  cost/DECODE(clicks,0,null,clicks) as cpc,
  conversions,
  CAST(conversions AS DECIMAL)/DECODE(clicks,0,null,clicks) as convr,
  cost/DECODE(conversions,0,null,conversions) as cpconv
FROM campaign_rates
WHERE advertiser_id = ? 
ORDER BY campaign_id;

CREATE PROCEDURE advertiser_simple_summary AS
SELECT * 
FROM campaign_rates 
WHERE advertiser_id = ? AND campaign_id = 1;

CREATE VIEW creative_rates AS
SELECT 
  advertiser_id, 
  campaign_id, 
  creative_id,
  COUNT(*) AS records, 
  SUM(is_impression) AS impressions, 
  SUM(is_clickthrough) AS clicks, 
  SUM(is_conversion) as conversions,
  SUM(cost) as cost
FROM event_data
GROUP BY advertiser_id, campaign_id, creative_id;

CREATE PROCEDURE campaign_summary AS
SELECT 
  creative_id,
  cost as spent,
  impressions,
  1000*cost/impressions as cpm,
  clicks,
  CAST(clicks AS DECIMAL)/impressions AS ctr, 
  cost/DECODE(clicks,0,null,clicks) as cpc,
  conversions,
  CAST(conversions AS DECIMAL)/DECODE(clicks,0,null,clicks) as convr,
  cost/DECODE(conversions,0,null,conversions) as cpconv
FROM creative_rates
WHERE advertiser_id = ? AND campaign_id = ?
ORDER BY creative_id;


CREATE VIEW advertiser_rates_minutely AS
SELECT 
  advertiser_id, 
  TRUNCATE(MINUTE,utc_time) as utc_min, 
  COUNT(*) AS records, 
  SUM(is_impression) AS impressions, 
  SUM(is_clickthrough) AS clicks, 
  SUM(is_conversion) as conversions,
  SUM(cost) AS spent
FROM event_data
GROUP BY advertiser_id, TRUNCATE(MINUTE,utc_time);

CREATE PROCEDURE advertiser_minutely_clicks AS
SELECT utc_min, clicks, conversions
FROM advertiser_rates_minutely
WHERE advertiser_id = ? 
ORDER BY utc_min DESC LIMIT 30;



CREATE PROCEDURE FROM CLASS procedures.TrackEvent;
PARTITION PROCEDURE TrackEvent ON TABLE event_data COLUMN creative_id PARAMETER 3;

CREATE PROCEDURE FROM CLASS procedures.AdvertiserSummary;
CREATE PROCEDURE FROM CLASS procedures.AdvertiserSimpleSummary;

