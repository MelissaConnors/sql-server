--https://github.com/MelissaConnors
--find databases with tables created in the past hour
--execute against master database
--adjust time in (SELECT DATEADD(HH, -1, GETDATE()))

DECLARE @sql nvarchar(max);
SET @sql = N'';
SELECT @sql = @sql + N'UNION ALL 
  SELECT DatabaseName = N''' + name + ''' COLLATE Latin1_General_BIN, 
  NumberOfCreatedTables =  
  (
    SELECT COUNT(*) as NumberOfCreatedTables
      FROM ' + QUOTENAME(name) + '.sys.tables t WITH (NOLOCK)'
   + N'
      WHERE [t].[create_date] >= (SELECT DATEADD(HH, -1, GETDATE()))
  )
  ' FROM sys.databases 
WHERE database_id > 4 AND state = 0; --ignore system tables

SET @sql = N'SELECT DatabaseName, NumberOfCreatedTables FROM 
(' + STUFF(@sql, 1, 10, N'') 
   + N') AS x 
   WHERE NumberOfCreatedTables > 0
   ORDER BY NumberOfCreatedTables DESC';

EXEC sys.sp_executesql @sql;

/*
--Run against databases in the results set
SELECT schema_name(schema_id), [name], create_date 
FROM sys.tables
WHERE create_date >= (SELECT CONVERT(DATE,GETDATE()))
ORDER BY create_date DESC;
*/
