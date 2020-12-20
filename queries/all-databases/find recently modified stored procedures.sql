--https://github.com/MelissaConnors
--find databases with stored procedures modified in the past hour
--execute against master database
--adjust time in (SELECT DATEADD(HH, -1, GETDATE()))
DECLARE @sql nvarchar(max);
SET @sql = N'';
SELECT @sql = @sql + N'UNION ALL 
  SELECT DatabaseName = N''' + name + ''' COLLATE Latin1_General_BIN, 
  NumberOfModifiedProcedures =  
  (
    SELECT COUNT(*) as NumberOfModifiedProcedures
      FROM ' + QUOTENAME(name) + '.sys.procedures p WITH (NOLOCK)'
   + N'
      WHERE [p].[modify_date] >= (SELECT DATEADD(HH, -1, GETDATE()))
	  AND [p].[modify_date] != [p].[create_date]
  )
  ' FROM sys.databases 
WHERE database_id > 4 AND state = 0; --ignore system databases

SET @sql = N'SELECT DatabaseName, NumberOfModifiedProcedures FROM 
(' + STUFF(@sql, 1, 10, N'') 
   + N') AS x 
   WHERE NumberOfModifiedProcedures > 0
   ORDER BY NumberOfModifiedProcedures DESC';

EXEC sys.sp_executesql @sql;
