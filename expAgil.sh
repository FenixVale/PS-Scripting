
export HOME=/root

echo "[INFO] Sync process has begun." > "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
objects=$(aws s3 ls s3://fuji-sftp/agiloft/ --human-readable --summarize | grep "Total Objects" | cut -d ' ' -f 3-)
echo "[INFO] Connected to AWS." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"

if [ "$objects" -gt 1 ]
then
        {
                
                echo "[INFO] Running Sync" >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                aws s3 sync s3://fuji-sftp/agiloft/ "/mnt/agiloftExport/$(date +%Y-%m-%d)-Export" 2>&1 | tee -a "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                echo "[INFO] Comparing files..." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"

                
                synced=$(ls -1 "/mnt/agiloftExport/$(date +%Y-%m-%d)-Export/" | wc -l)

                ##DEBUG
                #echo $synced
                #echo $objects

               
                if [ "$synced" -eq $(("$objects"-1)) ]
                then
                        {
                                
                                echo "[OK] No further sync required." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                                echo "[OK] Sync cycle run once." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                        }
                elif [ "$synced" -lt $(("$objects"-1)) ]
                then
                        {
                               
                                aws s3 sync s3://fuji-sftp/agiloft/ "/mnt/agiloftExport/$(date +%Y-%m-%d)-Export" 2>&1 | tee -a "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                                echo "[OK] Extra files synced on second pass." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                                echo "[OK] Sync cycle run twice." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                        }
                else
                        {
                                echo "[ERR] Unexpected comparison - terminating process." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                                exit
                        }
                fi

                
                aws s3 rm --recursive s3://fuji-sftp/ --exclude agiloft/ 2>&1 | tee -a "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
               
                echo "[OK] S3 Bucket (fuji-sftp) has been cleared." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
                echo "[OK] Sync has completed without errors." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"

        }

elif [ "$objects" -eq 1 ]
then
        {
                echo "[INFO] No sync performed - No files available for sync." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
        }

else
        {
                echo "[ERR] Directory missing, or AWS could not be contacted." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
        }
fi

echo "[INFO] Running directory cleanup." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
echo "[INFO] Clearing all files older than 3 days from export directory." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
find /mnt/agiloftExport/* -type d -mtime +3 | xargs rm -rfv 2>&1 | tee -a "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
echo "[INFO] Process complete." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
echo "[INFO] Export process complete." >> "/mnt/agiloftExport/$(date +%Y-%m-%d)-Log.log"
