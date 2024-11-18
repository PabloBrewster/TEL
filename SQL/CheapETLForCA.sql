-- Load control table and delta Merkle view for insert/update incremental transforms and Delta Factory loads, does not sync source deletes.
IF OBJECT_ID('load_control') IS NOT NULL
	DROP TABLE dbo.load_control;
GO

CREATE TABLE dbo.load_control 
(
	id INT IDENTITY(1,1) PRIMARY KEY, 
	load_start DATETIME, 
	load_end DATETIME, 
	row_count INT, 
	load_status varchar(10), 
	updated_at TIMESTAMP
);
GO

IF EXISTS (SELECT * FROM sys.views WHERE [name] = 'vw_transform_merkle')
	DROP VIEW dbo.vw_transform_merkle;
GO

CREATE VIEW [dbo].[vw_transform_merkle] AS
SELECT m.ID, m.Pattern_ID, m.Session_ID, m.x, m.y, m.updated_at,
	CAST('POLYGON( (' +
		CAST((x+1.2) AS VARCHAR(7)) + ' ' + CAST((y+1.2) AS VARCHAR(7)) + ','  +
		CAST((x) AS VARCHAR(7)) + ' ' + CAST((y+1.2) AS VARCHAR(7)) + ','  +
		CAST((x) AS VARCHAR(7)) + ' ' + CAST((y) AS VARCHAR(7)) + ','  +
		CAST((x+1.2) AS VARCHAR(7)) + ' ' + CAST((y) AS VARCHAR(7)) + ','  +
		CAST((x+1.2) AS VARCHAR(7)) + ' ' + CAST((y+1.2) AS VARCHAR(7)) +
	') )' AS GEOMETRY) AS grid_reference
FROM dbo.merkle m
WHERE m.updated_at > (SELECT ISNULL(MAX(updated_at),0) FROM dbo.load_control WHERE load_status NOT IN ('Failed','Running'));
GO
