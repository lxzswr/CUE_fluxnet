% read in the daily step flux data, and output it in an orgnized form.

function flux_dataset = readfluxnet_data(file_loc)

        % variables that needed
        var_need_v1={'TIMESTAMP','TA_F','SW_IN_F','VPD_F','P_F','GPP_NT_VUT_REF','GPP_DT_VUT_REF',...
        'NEE_CUT_REF','NEE_VUT_REF','RECO_NT_VUT_REF','RECO_DT_VUT_REF'};

        %read in the flux csv file, choose the correct time step 
        M2=readtable(file_loc);
        rawdata=table2array(M2); %convert table to matrix;
        txt=M2.Properties.VariableNames; %get the list of variables names    

        % the varibles to be extracted (var_need). Here, we can define it in the main function
        var_num = size(var_need_v1,2);

        %iniate input_gam, the output .MAT file name
        flux_dataset=nan(size(rawdata,1),var_num);


        colv=zeros(1,var_num);% used to store the col num of each variable in the csv file
        %------------find the col for each variable----%
            for x=1:var_num
                 tf = strcmp(txt,var_need_v1{x});
                 V1 = find(tf, 1, 'first');
                 if isempty(V1)
                     colv(1,x)=-1; %if there is no such variable, use -1999 to replace
                 else
                     colv(1,x)=V1;
                 end         
            end

           
           % assign values
           flux_dataset(:,1)=1; %site_id
           flux_dataset(:,2)=NaN; %pft, to be filled using another dataset

           flux_dataset(:,3)=round(rawdata(:,colv(1))./10000); %year

           tmp_month=round((rawdata(:,colv(1))-flux_dataset(:,3).*10000)./100);
           tmp_day=round((rawdata(:,colv(1))-flux_dataset(:,3).*10000-tmp_month(:,1).*100));
           flux_dataset(:,4)=datenum(flux_dataset(:,3),tmp_month,tmp_day)-datenum(flux_dataset(:,3),1,1)+1; %doy

           flux_dataset(:,5)=NaN; %lon, to be filled using another dataset
           flux_dataset(:,6)=NaN; %lat, to be filled using another dataset


            %climate variables, TA, SW, VPD, P
            for j= 7:10
                if colv(j-5) > 0 % only if the value exists
                    flux_dataset(:,j)=rawdata(:,colv(j-5));
                else
                    flux_dataset(:,j) = -9999;
                end
            end
            flux_dataset(:,9)=flux_dataset(:,9)./10; %for VPD, hpa to kpa!


            %carbon flux variables, GPP, NEE, Reco
            for j= 11:16
                if colv(j-5) > 0 % only if the value exists
                    flux_dataset(:,j)=rawdata(:,colv(j-5));
                else
                    flux_dataset(:,j) = -9999;
                end
            end

            %remove values not available
            flux_dataset(flux_dataset<-1000)=NaN;  


end