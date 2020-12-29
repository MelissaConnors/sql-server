--https://github.com/MelissaConnors
--find databases by name, count(*) for sys.indexes.disabled = 1 for clustered type
DECLARE @sql nvarchar(max);
SET @sql = N'';
SELECT @sql = @sql + N'UNION ALL 
  SELECT DatabaseName = N''' + name + ''' COLLATE Latin1_General_BIN, 
  NumberOfDisabledClusteredIndexes =  
  (
    SELECT COUNT(*) as NumberOfCreatedTriggers
      FROM ' + QUOTENAME(name) + '.sys.indexes i WITH (NOLOCK)'
   + N'
      WHERE [i].[type] = 1
	  AND [i].[is_disabled] = 1
  )
  ' FROM sys.databases 
WHERE database_id > 4 AND state = 0;

SET @sql = N'SELECT DatabaseName, NumberOfDisabledClusteredIndexes FROM 
(' + STUFF(@sql, 1, 10, N'') 
   + N') AS x 
   WHERE NumberOfDisabledClusteredIndexes > 0
   ORDER BY NumberOfDisabledClusteredIndexes DESC';

EXEC sys.sp_executesql @sql;

/*
Run against databases in the results set
select * from sys.indexes
where type = 1
AND is_disabled = 1
*/
