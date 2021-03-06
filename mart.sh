#!/data/data/com.termux/files/usr/bin/bash

# Do not edit this file unless you know what you are doing

me="\e[38;5;196m"
hi="\e[38;5;82m"
ku="\e[38;5;226m"
bi="\e[38;5;21m"
cya="\e[38;5;13m"
co="\e[38;5;202m"
mag="\e[38;5;14m"
bpu="\e[48;5;231m"
tbl="\e[1m"
dim="\e[2m"
no="\e[0m"

bnr() {
clear
clm=$(tput cols)
banner1="* M.A.R.T - Mobile Android ROM Translator *"
banner2="* by gk-dev *"
b1="$(printf "%*s\n" $(((${#banner1}+$clm)/2)) "$banner1")"
b2="$(printf "%*s\n" $(((${#banner2}+$clm)/2)) "$banner2")"
brs
echo -e "$bpu$tbl$co$b1$(printf "%*s\n" $(($clm-${#b1})))"
echo -e "$b2$(printf "%*s\n" $(($clm-${#b2})))$no"
brs
echo ""

}
brs() {
devider="$(printf '%*s' $clm | tr " " "=")"
echo -e "$tbl$mag$devider$no"
}

with_pm_check() {
	echo -e "${mag}$l_first_alert:\c "
	if [ -z "$(pm list packages | grep "termux.api")" ]; then
		echo -e "${me}$l_missing_dep_alert_termuxapi$no\n"
		sleep 3
		exit
	fi
	if [ -z "$(pm list packages | grep "per.pqy.apktool")" ]; then
		echo -e "${me}$l_missing_dep_alert_apktool$no\n"
		sleep 3
		exit
	fi
}

first_install() {
	if [ -z "$(pm list packages 2>&1 | grep "android.os.DeadObjectException")" ]; then
		with_pm_check
	fi
	yes | pkg up > /dev/null 2>&1
	yes | pkg install pv > /dev/null 2>&1
	echo -e "${ku}$l_depinstall$no\n"
	cat $tools/settings/dependencies | while read dep; do
		if [ -z "$(dpkg -l | grep "$dep")" ]; then
			echo -e "$l_notif_installing \"$dep\" \c"
			yes | pkg install $dep > /dev/null 2>&1
			echo -e "${hi}$l_notif_ok$no"
		else
			echo -e "$l_notif_installing \"$dep\" ${co}$l_notif_already_installed$no"
		fi
	done
	sleep 2
	busybox sed -i "s/settings_first_run=1/settings_first_run=0/g" $mart_set
	for i in {5..0}; do 
		printf "\r$l_notif_countdown_enter_menu" $i
		sleep 1
	done
	main_menu;
}

choose_language() {
	current_lang="$(cat $mart_set | grep "settings_language" | cut -d"=" -f2)"
	export crlng=$current_lang
	source $tools/lang/$current_lang
}

quit() {
	bnr;
	p "$l_exit_massage"
	figlet gk-dev
	echo -e "$no"
	exit
}

settings_menu() {
	repo_version="$(cat $mart_set | grep "settings_repo_version" | cut -d"=" -f 2)"
	repo_lang="$(cat $mart_set | grep "settings_repo_language" | cut -d"=" -f 2)"
	apktool_v="$(cat $mart_set | grep "settings_apktool" | cut -d"=" -f 2)"
	aapt_v="$(cat $mart_set | grep "settings_aapt" | cut -d"=" -f 2)"
	smali_v="$(cat $mart_set | grep "settings_smali" | cut -d"=" -f 2)"
	baksmali_v="$(cat $mart_set | grep "settings_baksmali" | cut -d"=" -f 2)"
	if [[ "$(cat $mart_set | grep "settings_auto_update" | cut -d"=" -f2)" == "1" ]]; then
		update_togle=""
		update_togle="$l_notif_update_on"
	else
		update_togle=""
		update_togle="$l_notif_update_off"
	fi
	bnr;
	ech="${tbl}${ku}$l_title_settings_menu${no}\n
$l_title_settings_summary_repo
 1) $l_title_settings_repositories_version @: $cya$repo_version$no
 2) $l_title_settings_lang_translate @: $cya$repo_lang$no\n
$l_title_settings_summary_apktool
 3) $l_title_settings_apktool_version @: $cya$apktool_v$no
 4) $l_title_settings_aapt @: $cya$aapt_v$no\n
$l_title_settings_summary_mart
 5) $l_title_settings_auto_update @: $cya$update_togle$no
 6) $l_title_settings_check_update
 7) $l_title_settings_mart_language\n 
 q) $ku$l_back_main$no\n"
	echo -e "$ech" | awk -F"@" 'NR==1,NR==18{ printf "%-25s %s\n", $1,$2} '
	brs;
	echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) #Choosing repo version
				bnr;
				echo -e "${tbl}${ku}$l_title_settings_repositories_version:$no\n"
				while :; do
				names=""
				names=( $(ls $tools/data/repositories/* | rev | cut -d"/" -f1 | rev) )
				dym opt in ${names[@]}
					if [ "$opt" != "" ]; then
						oldversion="$(cat $mart_set | grep "settings_repo_version" | cut -d"=" -f2)"
						busybox sed -i "s/$oldversion/$opt/g" $mart_set
						settings_menu;
					fi
				done; break;;
			2) #Choosing repo lang
				repover="$(cat $mart_set | grep "settings_repo_version" | cut -d"=" -f2)"
				bnr;
				echo -e "${tbl}${ku}$l_title_settings_repositories_lang:$no\n"
				while :; do
				replang=""
				replang="$(cat $tools/data/repositories/$repover | egrep -v '(^#|^$)' | grep "mart_repositories" | cut -d"=" -f3 | cut -d" " -f1)"
				dym opt in ${replang[@]}
					if [ "$opt" != "" ]; then
						oldlang="$(cat $mart_set | grep "settings_repo_lang" | cut -d"=" -f2)"
						busybox sed -i "s/$oldlang/$opt/g" $mart_set
						settings_menu;
					fi
				done; break;;
			3) #Choosing apktool version
				bnr;
				echo -e "${tbl}${ku}$l_title_settings_apktool_version:$no\n"
				while :; do
				names=""
				names=( $(ls $libapktool/apktool/* | grep "apktool-" | rev | cut -d"/" -f1 | rev) )
				dym opt in ${names[@]}
					if [ "$opt" != "" ]; then
						oldapktool="$(cat $mart_set | grep "settings_apktool" | cut -d"=" -f2)"
						busybox sed -i "s/$oldapktool/$opt/g" $mart_set
						settings_menu;
					fi
				done; break;;
			4) #Choosing aapt version
				bnr;
				echo -e "${tbl}${ku}$l_title_settings_aapt:$no\n"
				while :; do
				names=""
				names=( $(ls $libapktool/apktool/openjdk/bin/* | grep "aapt" | rev | cut -d"/" -f1 | rev) )
				dym opt in ${names[@]}
					if [ "$opt" != "" ]; then
						oldaapt="$(cat $mart_set | grep "settings_aapt" | cut -d"=" -f2)"
						busybox sed -i "s/$oldaapt/$opt/g" $mart_set
						settings_menu;
					fi
				done; break;;
			5) #Auto update options
				if [[ "$(cat $mart_set | grep "settings_auto_update" | cut -d"=" -f2)" == "1" ]]; then
					echo -e "$mag"
					toggle_auto_update="$l_auto_update_off"
					choice=""
					read -n 1 -p "$toggle_auto_update" choice
						if [[ $choice = "y" ]]; then
							busybox sed -i "s/settings_auto_update=1/settings_auto_update=0/g" $mart_set
							echo -e "$no"
							settings_menu;
						else
    						settings_menu;
    					fi
				elif [[ "$(cat $mart_set | grep "settings_auto_update" | cut -d"=" -f2)" == "0" ]]; then
					echo -e "$mag"
					toggle_auto_update="$l_auto_update_on"
					choice=""
					read -n 1 -p "$toggle_auto_update" choice
						if [[ $choice = "y" ]]; then
							busybox sed -i "s/settings_auto_update=0/settings_auto_update=1/g" $mart_set
							echo -e "$no"
							settings_menu;
						else
    						settings_menu;
    					fi
				fi; break;;
			6) check_update; break;;
			7) #language settings
				bnr;
				echo -e "${tbl}${ku}$l_title_settings_repositories_lang:${no}\n"
				names=""
				names=( $(ls $tools/lang | cut -d"-" -f1) )
				dym opt in ${names[@]}
				if [ "$opt" != "" ]; then
					echo -e "${tbl}${cya}$opt${no} $l_title_settings_choosen_mart_lang"
					busybox sed -i "s/$crlng/${opt}-lng/g" $mart_set
					echo -e "\n$l_notif_restart_choosen_lang\n"
					sleep 3
					./mart.sh
				fi; break;;
			q) main_menu; break;;
			y) isntall_update; break;;
			*) echo -e "${me}$l_title_main_menu_wrong_options${no}";;
		esac
	done
}

check_update(){
	bnr;
	echo -e "${ku}$l_check_update${no}\c"
	newv="$(curl -s curl https://raw.githubusercontent.com/rendiix/M.A.R.T/master/README.md | grep "MART V" | cut -d" " -f3 | cut -d"." -f3)"
	curv="$(grep "MART V" README.md | cut -d" " -f3 | cut -d"." -f3)"
	if [ -z "$newv" ]; then
		echo -e " ${me}$l_check_update_error${no}"
		sleep 2
		main_menu;
			else 
				if [ "$curv" -eq "$newv" ]; then
					echo -e " ${hi}$l_no_update${no}"
					sleep 2
					main_menu;
						else
							if [ "$curv" -lt "$newv" ]; then
								export update_avail="$update_avail"
								echo -e "\n${ku}$l_update_avail${no} ${co}V$newv"
								echo -e "\n${hi}$l_downloading_update$mag\n"
								mkdir temp
								wget https://codeload.github.com/rendiix/M.A.R.T/zip/master -O $root/temp/mart.zip
								echo -e "\n${hi}$l_install_update\c"
								7z x -o$root/temp/ $root/temp/mart.zip > /dev/null 2>&1
								cp -R $root/temp/*/* $root
								rm -R $root/temp
								chmod +x *
								chmod +x tools/*
								echo -e " ${hi}$l_notif_done${no}\n"
									for i in {5..0}; do 
										printf "\a\r$l_notif_countdown_restart" $i
										sleep 1
									done
								reset 2&1>/dev/null
								./mart.sh
							fi
				fi
	fi
}

menu_new_project() {
	while :; do
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	romname=""
	romname1=""
	bnr
	echo -e "${ku}$l_create_new_project$no\n"
	read -p "" romname1
	export romname=$(echo "$romname1" | busybox sed 's/ /_/g' | busybox sed 's/@/_/g')
	if [[ -z "$romname" ]]; then
		bnr;
		echo -e "${me}$l_notif_error${no} \n"
		echo -e "$l_create_new_project_empty_input"
		sleep 2
		continue
	fi
		if [[ ! $(ls -d $target/*/ 2>/dev/null | grep "mart_$romname/") ]]; then
			mkdir -p $target/mart_$romname/.logs
			mkdir -p $target/mart_$romname/.tmp
			cp $setfd/project_info $target/mart_$romname/.tmp
			if [[ -z "$currentpr" ]]; then
				busybox sed -i "s/settings_current_project=/settings_current_project=mart_$romname/g" $mart_set
				else
				busybox sed -i "s/$currentpr/mart_$romname/g" $mart_set
			fi
			main_menu;
		else
			bnr;
			echo -e "${me}$l_notif_error${no} \n"
			echo -e "$l_create_new_project_already"
			sleep 2
			romname=""
			continue
		fi
	done
}

menu_continue_project() {
	while :;do
	bnr;
	echo -e "${tbl}${ku}$l_continue_project_summary$no\n"
	names=( $(ls -d $target/* | grep "mart_" | rev | cut -d"/" -f1 | rev) )
			dym opt in ${names[@]}
			if [ "$opt" != "" ]; then
				echo -e "\n${cya}$opt${no} $l_continue_project_choosen"
				busybox sed -i "s/$currentpr/$opt/g" $mart_set
				sleep 2
				main_menu;
			fi
			break
		done
}

menu_delete_project() {
	while :; do
	countp=""
	countp=$(ls -d $target/* 2>/dev/null | grep "mart_" | wc -l)
		if [ "$countp" = "0" ]; then
			menu_new_project;
		fi
	bnr;
	echo -e "${tbl}${ku}$l_delete_project_summary${no}\n"
	names=( $(ls -d $target/* 2>/dev/null | grep "mart_" | rev | cut -d"/" -f1 | rev) )
	currentpr=""
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	dym opt in ${names[@]}
        	if [ "$opt" != "" ]; then
        		if [ "$opt" = "$currentpr" ]; then
        			rm -R $target/$opt
        			changepr=( $(ls -d $target/* 2>/dev/null | grep "mart_" | rev | cut -d"/" -f1 | rev | head -1) )
        			busybox sed -i "s/$currentpr/$changepr/g" $mart_set
        		else
        			rm -R $target/$opt
        		fi
        			echo -e "\n${cya}$opt${no} $l_delete_project_choosen"
        			sleep 2
        		continue
        	fi
        break
        done
}


dym() {
	local v e
	declare -i i=1
	v=$1
	shift 2
	for e in "$@" ; do
		echo -e " ${tbl}${i})${no} ${mag}$e${no}"
		i=i+1
	done | pr -ts" " --columns 2 | column -t
	echo -e "\n${tbl}${ku} b) $l_back_main$no"
	echo -e "\n${tbl}$l_insert_options$no"
	read -i "" REPLY
	if [ "$REPLY" = "b" ]; then
		main_menu;
	fi
	i="$REPLY"
		if [[ $i -gt 0 && $i -le $# ]]; then
		export $v="${!i}"
		else
		echo -e "${tbl}${me}$l_wrong_input${no}"
		export $v=""
		sleep 2
		fi
}

about_mart() {
	repo_version="$(cat $mart_set | grep "settings_repo_version" | cut -d"=" -f 2)"
	repo_lang="$(cat $mart_set | grep "settings_repo_language" | cut -d"=" -f 2)"
	bnr;
	about="$mag$(cat $setfd/about)"
	p "$about"
	about2=$(cat $tools/data/repositories/$repo_version | egrep -v '(^#|^$)' | grep "mart_repositories" | cut -d"=" -f3 | busybox sed -r 's/ / by: /g' | while read credit; do
		echo -e "  • $credit"
	done)
	p "$mag$about2"
	echo -e "\n$l_enter_back$no"
	read -s -n 1
	main_menu;
}

xml_main() {
	bnr;
	test_connection;
	echo -e "${hi}$l_xml_start$no\n"
	if [ "$concheck" = "FAILED" ]; then
		xml_menu;
	fi
	if [ ! -f "$xml_dir/strings.xml" ]; then
		echo -e "${co}$l_no_xml_file$no"
		sleep 2
		func_continue;
		xml_main;
	fi
	$trans $xin $xout $xml_dir/*.xml
	
}

test_connection() {
	bnr;
	echo -e "${hi}$l_check_con_title$no... \c"
	if [ -z "$(curl -s --head http://www.google.com | head -n1)" ]; then
		echo -e " ${me}$l_notif_error${no}"
		echo -e "\n${ku}$l_check_con_error${no}\n\n${ku}$l_check_con_error_tips$no"
		export concheck="FAILED"
		read -s
	else
		sleep 3
		echo -e "${tbl}${ku}$l_notif_ok$no"
		export concheck="OK"
	fi
}
xml_menu() {
	trans="$tools/data/xml_translator/*.py"
	lconf="$datadir/xml_translator/xml_translator.cfg"
	xml_dir="$target/$currentpr/XML-translator"
	xml_source="$(cat $lconf | grep "xml_source" | cut -d"=" -f2)"
	xml_target="$(cat $lconf | grep "xml_target" | cut -d"=" -f2)"
	xin="$(cat $lconf | grep "xml_code_in" | cut -d"=" -f2)"
	xout="$(cat $lconf | grep "xml_code_out" | cut -d"=" -f2)"
	xml_tengine="$(cat $lconf | grep "xml_translate_engine" | cut -d"=" -f2)"
	if [ ! -d "$xml_dir" ]; then
		mkdir -p $xml_dir
	fi
	bnr;
	xmlmenu="${ku}$l_title_main_menu_info$no\n${co}$l_xml_alert$no\n
${tbl}${ku}$l_title_xml_translator_menu:$no\n
  1) $l_title_xml_source @: ${cya}$xml_source$no
  2) $l_title_xml_target @: ${cya}$xml_target$no
  3) $l_title_xml_translate_engine @: ${cya}$xml_tengine$no\n 
  t) $l_title_do_xmltrans\n
  ${ku}b) $l_back$no\n"
	echo -e "$xmlmenu" | awk -F"@" 'NR==1,NR==20{ printf "%-30s %s\n", $1,$2} '
	echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) #Insert source lang
				sourcelang=""
				while [[ -z "$sourcelang" ]]; do
					bnr;
					echo -e "${tbl}${ku}$l_title_xml_insert_code_lng$no"
					slang=""
					read -e slang
					if [ -z "$slang" ]; then
						echo -e "${me}$l_create_new_project_empty_input$no"
						sleep 2
						elif [ -z "$(cat $lconf | grep ":$slang" | head -n1)" ]; then
						echo -e "\n\"$slang\" ${co}$l_xml_lng_not_exist$no"
						sleep 2
						else
						sourcelang="$(cat $lconf | grep ":$slang" | head -n1 | cut -d":" -f1)"
						old="$(cat $lconf | grep "xml_source" )"
						oldc="$(cat $lconf | grep "xml_code_in" )"
						busybox sed -i "s/$old/xml_source=$sourcelang/g" $lconf
						busybox sed -i "s/$oldc/xml_code_in=$slang/g" $lconf
						echo -e "\n${hi}$l_xml_source_choosen:${no} \"$sourcelang\""
						sleep 2
						xml_menu;
					fi
				done
				break;;
			2) #Insert target lang
				targetlang=""
				while [[ -z "$targetlang" ]]; do
					bnr;
					echo -e "${tbl}${ku}$l_title_xml_insert_code_lng$no"
					slang=""
					read -e slang
					if [ -z "$slang" ]; then
						echo -e "${me}$l_create_new_project_empty_input$no"
						sleep 2
						elif [ -z "$(cat $lconf | grep ":$slang" | head -n1)" ]; then
						echo -e "\n\"$slang\" ${co}$l_xml_lng_not_exist$no"
						sleep 2
						else
						targetlang="$(cat $lconf | grep ":$slang" | head -n1 | cut -d":" -f1)"
						old="$(cat $lconf | grep "xml_target" )"
						oldc="$(cat $lconf | grep "xml_code_out" )"
						busybox sed -i "s/$old/xml_target=$targetlang/g" $lconf
						busybox sed -i "s/$oldc/xml_code_out=$slang/g" $lconf
						echo -e "\n${hi}$l_xml_target_choosen:${no} \"$targetlang\""
						sleep 2
						xml_menu;
					fi
				done
				break;;
			3) #Choose translate engine 
				bnr;
				echo -e "${tbl}${ku}$l_title_xml_translate_engine:$no\n"
				while :; do
				names=""
				names=( $($trans -S | tr -s ' ' | cut -d" " -f2) )
				dym opt in ${names[@]}
					if [ "$opt" != "" ]; then
						old="$(cat $lconf | grep "xml_translate_engine" | cut -d"=" -f2)"
						busybox sed -i "s/$old/$opt/g" $lconf
						xml_menu;
					fi
				done; break;;
			t) xml_main; break;;
			b) menu_build; break;;
			*) echo -e "${me}$l_wrong_input${no}";;
		esac
	done
}

values_pick() {
	bnr;
	echo -e "${tbl}${ku}$l_choose_locale:$no\n"
	while :; do
		localelist=$(cat $datadir/locale/locale_list | cut -d" " -f1)
		dym opt in ${localelist[@]}
			if [ "$opt" != "" ]; then
				val0="$opt"
				val1="$(cat $datadir/locale/locale_list | grep "$opt" | cut -d" " -f2)"
				val2="$(cat $datadir/locale/locale_list | grep "$opt" | cut -d" " -f3)"
			fi
			if [ "$val2" != "" ]; then
				eval2=", values-$val2"
			fi
			bnr
			echo -e "${tbl}${ku}$l_locale_picked:$no\n"
			echo -e "$l_locale_name: $opt"
			echo -e "$l_locale_code: $val1"
			echo -e "$l_locale_variant: $val2"
			echo -e "$l_locale_folder: values-$val1$eval2\n"
		break
	done
	echo -e "\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >$logdir/install_framework.logs
	echo -e "${hi}$l_install_framework$no"
	logdir="$target/$currentpr/.tmp"
	cat $tools/data/framework/framework_list | egrep -v '(^#|^$)' | while read flist; do
			$apktool if $workdir/$flist >$logdir/install_framework.logs 2>&1
		done
	brs;
	echo -e "${hi}$l_start_decode$no"
	if [ ! -d "$target$/currentpr/values_$val0" ]; then
		mkdir -p $workdir/values_$val0
	fi
	decode="$target/$currentpr/apk_decode"
	values_dump="$target/$currentpr/values_$val0"
	echo -e "\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >$logdir/decompile.log
	find $workdir/system/ -name "*.apk" | while read apk; do
	apkname=$(basename $apk)
	brs;
	echo -e "${hi}$l_decompiling: ${mag}$apkname$no"
	$apktool d -s -f $apk -o $decode/$apkname >$logdir/decompile.log
	if [ "$val2" = "$val2" ]; then
		inval2="$(find $decode/$apkname -type d -name "values-$val2")"
		outval2="$(find $decode/$apkname -type d -name "values-$val2" | busybox sed "s/apk_decode/values-$val0/")"
		if [ "$inval2" != "" ]; then
			echo -e "${hi}$l_copying_apk values-$val1$no\n"
			mkdir -p $outval2
			cp -R $inval2/* $outval2
		fi
	fi
	inval="$(find $decode/$apkname -type d -name "values-$val1")"
	outval="$(find $decode/$apkname -type d -name "values-$val1" | busybox sed "s/apk_decode/values-$val0/")"
	if [ "$inval" != "" ]; then
		echo -e "${hi}$l_copying_apk values-$val1$no\n"
		mkdir -p $outval
		cp -R $inval/* $outval
	fi
	rm -R $decode/$apkname
	done
	brs
	echo -e "${hi}$l_notif_done$no\n"
	echo -e "$l_file_store_at: ${mag}$target/$currentpr/values_$val0$no"
	sleep 5
	menu_extra
}

translate_main() {
	repv="$(cat $mart_set | grep "settings_repo_version" | cut -d"=" -f2)"
	replang=""
	replang="$(cat $mart_set | grep "settings_repo_language" | cut -d"=" -f2)"
	replink="$(cat $tools/data/repositories/$repv | egrep -v '(^#|^$)' | grep "$replang" | grep "mart_repositories" | cut -d"=" -f2)"
	bnr;
	if [ ! -d "$workdir/system" ]; then
		echo -e "${me}$l_no_systemdir: ${co}$workdir/system$no"
		func_continue
		translate_main
		fi
	echo -e "${co}$l_repo_download$no\c"
	if [ ! -d "$tools/data/repo_download/$replang" ]; then
		git clone $replink $tools/data/repo_download/$replang >/dev/null 2>&1
		echo -e " ${hi}OK$no"
		else
		sleep 3
		echo -e " ${hi}OK$no"
	fi
	echo -e "\n\n\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >>$logdir/install_framework.log
	echo -e "${co}$l_install_framework$no\c"
	cat $tools/data/framework/framework_list | egrep -v '(^#|^$)' | while read flist; do
			$apktool if $workdir/$flist >>$logdir/install_framework.log 2>&1
		done
	echo -e " ${hi}OK$no"
	echo -e "\n${co}$l_start_decode$no"
	if [ ! -d "$workdir/apk_decode" ]; then
		mkdir -p $workdir/apk_decode
	fi
	decode="$workdir/apk_decode"
	echo -e "\n\n\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >>$logdir/decompile.log
	find $workdir/system/ -name "*.apk" | while read apk; do
	apkname=$(basename $apk)
		if [ "$(find $tools/data/repo_download/$replang/ -type d -name "$apkname" | rev | cut -d"/" -f1 | rev)" == "$(find $target/$currentpr/system/ -type f -name "$apkname" | rev | cut -d"/" -f1 | rev)" ]; then
			brs;
			echo -e "${co}$l_decompiling: ${mag}$apkname$no"
			$apktool d -s -f $apk -o $decode/$apkname >>$logdir/decompile.log 2>&1
			vin="$(find $tools/data/repo_download/$replang/ -type d -name "$apkname")"
			vout="$(find $workdir/apk_decode/ -maxdepth 1 -type d -name "$apkname")"
			if [ "$(find $tools/data/repo_download/$replang/ -type d -name "$apkname" | rev | cut -d"/" -f1 | rev)" == "$(find $target/$currentpr/apk_decode/ -maxdepth 1 -type d -name "$apkname" | rev | cut -d"/" -f1 | rev)" ]; then
				echo -e "\n${co}$l_insert_values_lng$no\c"
				cp -R $vin/res/* $vout/res/
				echo -e " ${hi}OK$no"
			fi
			echo -e "\n\n\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >>$logdir/compile.log
			echo -e "\n${co}$l_building: ${mag}$apkname$no\c"
			$apktool b -c $decode/$apkname >>$logdir/compile.log 2>&1
			if [ -d "$workdir/apk_decode/$apkname/dist" ]; then
				apkin="$(find $workdir/apk_decode/$apkname/dist/ -type f -name "$apkname")"
				apkout="$(find $workdir/system/ | grep  "/$apkname" | busybox sed "s/\/$apkname/\//g")"
				cp -R $decode/$apkname/dist/* $apkout
				rm -R $decode/$apkname
				echo -e " ${hi}OK$no"
				else
				rm -R $decode/$apkname
				echo -e " ${me}$l_notif_error${no}"
				echo -e "\n${mag}$apkname ${ku}$l_cant_translate_apk$no\n"
				echo "$apkname" >>$logdir/list_apk_failed.log
			fi
		fi
		done
		failed_list="$(cat $logdir/list_apk_failed.log)"
		echo -e "\n${tbl}${ku}$l_list_apk_failed$no\n"
		echo -e "${mag}$failed_list$no"
		echo -e "\n${tbl}${ku}$l_list_apk_failed_tips$no"
		rm $logdir/list_apk_failed.log
		sleep 5
}

extract_zip() {
	bnr;
	findzip=""
	findzip="$(ls $workdir | grep ".zip")"
		if [ -z $findzip ]; then
			echo -e "${me}$l_notif_error${no}\n"
			echo -e "$l_extract_missing_zip ${co}$currentpr$no"
			sleep 5
			func_continue;
		else
			zipfile="$(basename $findzip)"
			oldnamezip="$(cat $setfd/project_info | grep "mart_zip_orig_name" | cut -d"=" -f2)"
			busybox sed -i "s/$oldnamezip/$zipfile/g" $workdir/.tmp/project_info
			echo -e "\n\n\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >>$logdir/extract_zip.log
			echo -e "$l_extract_notif ${co}$zipfile...$no\c"
			mkdir $workdir/orig_rom
			7z x $workdir/$zipfile -o$workdir/orig_rom >>$logdir/extract_zip.log 2>&1
			if [ ! -d "$workdir/orig_rom/system" ]; then
				mv -f $workdir/orig_rom/system/system.new.dat $workdir/
				mv -f $workdir/orig_rom/system/system.transfer.list $workdir/
				mv -f $workdir/orig_rom/system/file_contexts.* $workdir/
				unpack_dat
			else
				mv -f $workdir/orig_rom/system $workdir/system
			fi
			bnr;
			echo -e " ${hi}$l_extract_done\n"
			sleep 3
		fi
}

unpack_dat() {
			export d2m=$tools/imgtools/sdat2img.py
			bnr;
			echo -e "\n\n\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >>$logdir/extract_dat.log
			echo -e "${co}$l_extract_unpack_notif ${mag}$typeimg${no}${mag}\c"
			$d2m $workdir/system.transfer.list $workdir/system.new.dat $workdir/.tmp/raw.img >>$logdir/extract_dat.log 2>&1
			rm {$workdir/system.new.dat,$workdir/system.transfer.list}
			imgsize="$(wc -c $workdir/.tmp/raw.img | cut -d" " -f1)"
			oldnameimgsize="$(cat $setfd/project_info | grep "mart_getimgsize" | cut -d"=" -f2)"
			busybox sed -i "s/$oldnameimgsize/$imgsize/g" $workdir/.tmp/project_info
			mkdir $workdir/system
			7z x -o$workdir/system/ $workdir/.tmp/raw.img
			rm $workdir/.tmp/raw.img
			echo -e " ${tbl}${hi}$l_notif_ok$no\n"
}

repack_dat() {
	if [ -f "$workdir/file_contexts.bin" ]; then
		echo -e "${ku}$l_fc_type_alert$no\c"
		$tools/extratools/sefcontext_decompile -o $workdir/file_contexts $workdir/file_contexts.bin
		sleep 2
		echo -e " ${tbl}${hi}$l_notif_done$no\n"
		sleep 2
	fi
	echo -e "\n\n\n----------[$(date +%Y-%m-%d" "%H:%M:%S)]----------\n" >>$logdir/repack_dat.log
	echo -e "${ku}$l_build_img\n$no\c"
	ukuran="$(cat $workdir/.tmp/project_info | grep "mart_getimgsize" | cut -d"=" -f2)"
    $imgtools/make_ext4fs -T -0 -S $workdir/file_contexts -L system -l ${ukuran} -a system $workdir/.tmp/raw.img $workdir/system/ >>$logdir/repack_dat.log 2>&1
    echo -e "${hi}$l_notif_done$no\n"
    sleep 2
    echo -e "${ku}$l_make_sparse$no\c"
    $imgtools/img2simg $workdir/.tmp/raw.img $workdir/.tmp/sparse.img 4096
    rm -r $workdir/.tmp/raw.img
    echo -e " ${hi}$l_notif_done$no\n"
    sleep 2
    echo -e "${ku}$l_make_dat${no}\c"
    echo -e "$mag"
    api="$(cat $workdir/system/build.prop | grep "ro.build.version.sdk" | cut -d"=" -f 2)"
	if [[ $api = "21" ]]; then
			is="1"
		elif [[ $api = "22" ]]; then
			is="2"
		elif [[ $api = "23" ]]; then
			is="3"
		elif [[ $api -ge "24" ]]; then
			is="4"
    fi
    $imgtools/img2sdat.py $workdir/.tmp/sparse.img -o $workdir/.tmp/ -v ${is} >>$logdir/repack_dat.log 2>&1
    rm -r $workdir/.tmp/sparse.img
    echo -e "${no} ${hi}$l_notif_done$no\n"
}

repack_zip() {
    p "${hi}$l_compress_zip\n$no\c"
    mv $workdir/.tmp/system.* $workdir/orig_rom/
	echo -e "${ku}$l_insert_zip_name$no"
	read zipname1
	if [ -z "$zipname1" ]; then
		export zipname="$currentpr"
		else
		export zipname=$(echo "$zipname1" | busybox sed 's/ /_/g' | busybox sed 's/@/_/g')
	fi
	cd $workdir/orig_rom/
	zip -r $workdir/${zipname}.zip .
	echo -e "\n${hi}$l_build_done_alert$no"
	echo -e "\n$workdir/${zipname}.zip\n"
	cd $root
	sleep 3
}

debloat_menu() {
	bnr;
	echo -e "${tbl}${ku}$l_list_debloat$no\n"
	dlist=( $(ls -d $tools/data/debloat/* | rev | cut -d"/" -f1 | rev) )
		dym opt in ${dlist[@]}
		if [ "$opt" != "" ]; then
			bnr;
			cat $tools/data/debloat/$opt | egrep -v '(^#|^$)' | while read list; do
			find $workdir/system/ -name "$list" -exec rm -r "{}" \; 2>/dev/null | echo -e "${mag}$l_deleting_bloatware: ${hi}$list$no"
			done
			olddeb="$(cat $setfd/project_info | grep "mart_debloat_info" | cut -d"=" -f2)"
			busybox sed -i "s/$olddeb/mart_debloat_info=1/g" $workdir/.tmp/project_info
			sleep
			menu_extra;
		fi
}

menu_repack_project() {
	bnr;
	echo -e "${ku}$l_repack_summary$no\n\n
 1) $l_translate_menu
 2) $l_repack\n\n
 ${ku}b) $l_back$no\n
 ${ku}$l_insert_options$no\n"
	while read env; do
		case $env in
			1) # Translate main
				translate_main;
				menu_repack_project; break;;
			2) # Build ZIP
				bnr;
				repack_dat;
				repack_zip;
				menu_repack_project; break;;
			b) main_menu; break;;
			*) echo -e "${tbl}${me}$l_wrong_input${no}"
		esac
	done
}

menu_extra() {
	bnr;
	if [[ "$(cat $workdir/.tmp/project_info | grep "mart_debloat_info" | cut -d"=" -f2)" == "0" ]]; then
		debloattogle="${me}$l_notif_no${no}"
	else
		debloattogle="${hi}$l_notif_yes${no}"
	fi
	echo -e "${tbl}${ku}$l_build_rom_menu${no}\n
  1) $l_xml_translate_menu
  2) $l_values_pick
  3) $l_debloat_menu : $l_debloat_status_toggle = $debloattogle
  4) $l_unpack_repack_dat
  5) $l_sefcontext_convert
  6) $l_unpack_repack_bootimg\n
  ${ku}b) $l_back$no\n"
	echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) xml_menu; break;;
			2) values_pick; break;;
			3) debloat_menu; break;;
			4) unpack_repack_dat; break;;
			b) main_menu; break;;
			*) echo -e "${me}$l_wrong_input${no}";;
		esac
	done
}

unpack_repack_dat() {
	bnr;
	echo -e "${tbl}${ku}$l_unpack_repack_dat_menu$no\n
  1) $l_urd_unpack
  2) $l_urd_repack\n
  ${ku}b) $l_back$no"
  echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) startunpackdat; break;;
			2) startrepackdat; break;;
			b) menu_extra; break;;
			*) echo -e "${me}$l_wrong_input${no}";;
		esac
	done
}

startunpackdat() {
				bnr;
				filecheck=1
				list=$(echo -e "file_contexts.bin\nsystem.new.dat\nsystem.transfer.list")
				while read file; do
					if [ ! -f "$workdir/$file" ];then
						echo -e "$l_notif_file_notexist: ${co}$file$no"
						filecheck=""
					fi
				done <<< "$list"
				if [ -z "$filecheck" ]; then
					func_continue;
					startunpackdat
				else
					unpack_dat;
					unpack_repack_dat
				fi
}

startrepackdat() {
	bnr:
	if [ ! -d "$workdir/system" ]; then
		echo -e "${ku}$l_no_systemdir ${co}$workdir$no"
		sleep 5
		unpack_repack_dat;
	else
	bnr;
	repack_dat
	mkdir $workdir/output_DAT
	mv $workdir/.tmp/system.new.dat $workdir/output_DAT/
	mv $workdir/.tmp/system.patch.dat $workdir/output_DAT/
	mv $workdir/.tmp/system.transfer.list $workdir/output_DAT/
	echo -e "${hi}$l_file_store_at: ${co}$workdir/output_DAT/$no"
	sleep 5
	unpack_repack_dat;
	fi
}

func_continue() {
	echo -e "\n${ku}$l_func_continue$no"
	read -n 1 func
		if [ "$func" = "q" ]; then
			quit
		elif [ -z "$func" ]; then
			sleep 2
		else
			echo -e " ${me}$l_wrong_input${no}"
			func_continue;
		fi
}

main_menu() {
	bnr;
	countp=""
	countp=$(ls -d $target/* 2>/dev/null | grep "mart_" | wc -l)
	if [[ "$countp" = "0" ]]; then
		menu_new_project;
		fi
	currentpr="$(cat $mart_set | grep "settings_current_project" | cut -d"=" -f 2)"
	export workdir=$target/$currentpr
	logdir="$workdir/.tmp"
	mmenu="${tbl}${ku}$l_title_main_menu_info${no}\n
$l_title_main_menu_current_project @: ${cya}$currentpr$no
$l_title_main_menu_mart_version @: ${mag}$mart_version$no ${hi}$update_avail$no\n
${tbl}${ku}$l_title_main_menu${no}\n
  1) $l_title_main_menu_new_project
  2) $l_title_main_menu_continue_project
  3) $l_title_main_menu_delete_project
  4) $l_title_main_menu_repack_project
  5) $l_title_main_menu_extra
  6) $l_title_main_menu_settings\n
  i) $l_title_main_menu_about\n 
  ${me}q) $l_exit$no\n"
	echo -e "$mmenu" | awk -F"@" 'NR==1,NR==20{ printf "%-15s %s\n", $1,$2} '
	brs
	echo -e "${ku}$l_insert_options${no}";
	while read env; do
		case $env in
			1) menu_new_project; break;;
			2) menu_continue_project; break;;
			3) menu_delete_project; break;;
			4) menu_repack_project; break;;
			5) menu_extra; break;;
			6) settings_menu; break;;
			i) about_mart; break;;
			q) quit; break;;
			*) echo -e "${me}$l_wrong_input${no}";;
		esac
	done
}

termux-setup-storage
gkhome=$(pwd)
export root=$gkhome
cd $root
export tools=$root/tools
export imgtools=$tools/imgtools
target=~/storage/shared/M.A.R.T
libapktool=/data/data/per.pqy.apktool
mart_set="$tools/settings/settings"
setfd="$tools/settings"
apktool="$tools/apktool/apktool"
datadir="$tools/data"
mart_version=$(grep "MART V" README.md | cut -d" " -f3)
source $tools/settings/demo -w0.1
DEMO_PROMPT=""
curret_version=$(grep "# MART V" README.md | cut -d" " -f3)
choose_language;

if [ ! -d $target ]; then
	first_install;
	elif [ "$(cat $mart_set | grep "settings_auto_update" | cut -d"=" -f2)" == "1" ]; then
		check_update;
		main_menu;
	else
		main_menu
fi
