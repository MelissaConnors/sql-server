--https://github.com/MelissaConnors
--find databases with stored procedures created in the past hour
--adjust time in (SELECT DATEADD(HH, -1, GETDATE()))
DECLARE @sql nvarchar(max);
SET @sql = N'';
SELECT @sql = @sql + N'UNION ALL 
  SELECT DatabaseName = N''' + name + ''' COLLATE Latin1_General_BIN, 
  NumberOfCreatedProcedures =  
  (
    SELECT COUNT(*) as NumberOfCreatedProcedures
      FROM ' + QUOTENAME(name) + '.sys.procedures p WITH (NOLOCK)'
   + N'
      WHERE [p].[create_date] > (SELECT DATEADD(HH, -1, GETDATE()))
  )
  ' FROM sys.databases 
WHERE database_id > 4 AND state = 0;

SET @sql = N'SELECT DatabaseName, NumberOfCreatedProcedures FROM 
(' + STUFF(@sql, 1, 10, N'') 
   + N') AS x 
   WHERE NumberOfCreatedProcedures > 0
   ORDER BY NumberOfCreatedProcedures DESC';

EXEC sys.sp_executesql @sql;

/*run against databases in list
SELECT [name], create_date FROM sys.procedures
WHERE create_date > (SELECT CONVERT(DATE,GETDATE()))
*/
