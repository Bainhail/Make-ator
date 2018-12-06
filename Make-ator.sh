#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Make-ator.sh                                       :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: naali <marvin@42.fr>                       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2018/12/03 16:41:14 by naali             #+#    #+#              #
#    Updated: 2018/12/04 21:04:46 by naali            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

createheader ()
{
	iam=$(whoami)
	size_iam=$(echo $iam | wc -c)
	space1="                            "
	space2="                 "
	((size_iam--))
	dnow=$(date +'%Y/%m/%d')
	hnow=$(date +'%T')

	echo "#******************************************************************************#" > $1
	echo "#                                                                              #" >> $1
	echo "#                                                         :::      ::::::::    #" >> $1
	echo "#    Makefile                                           :+:      :+:    :+:    #" >> $1
	echo "#                                                     +:+ +:+         +:+      #" >> $1
	echo "#    By: $iam <marvin@42.fr>${space1:size_iam}+#+  +:+       +#+         #" >> $1
	echo "#                                                 +#+#+#+#+#+   +#+            #" >> $1
	echo "#    Created: $dnow $hnow by $iam${space2:size_iam-1}#+#    #+#              #" >> $1
	echo "#    Updated: $dnow $hnow by $iam${space2:size_iam}###   ########.fr        #" >> $1
	echo "#                                                                              #" >> $1
	echo "#******************************************************************************#" >> $1
    echo "" >> $1
}

addName ()
{
    read -p "Nom du programme? " name
    echo "NAME\t=\t$name" >> $1
    echo "" >> $1
}

addCompilo ()
{
	asw="0"
	while [ $asw != "1" ] && [ $asw != "2" ]
	do
		read -p "Choisissez un compilateur ([1=gcc] [2=plus tard]): " asw
	done

	if [ $asw = "1" ]
	then
		CC="CC"
		cc="gcc"
	elif [ $asw = "2" ]
	then
		CC="CC" # En attendant mieux
		cc="mettre compilo ici"
	fi
	if [ $cc ]
	then
		echo "$CC\t\t=\t$cc" >> $1
		echo "" >> $1
	else
		echo "$CC\t\t=\t#Mettre le compilo ici" >> $1
		echo "" >> $1
	fi
}

addFlags ()
{
	flg="-Wall -Wextra -Werror"
	asw=0
	while [ $asw != 'o' ] && [ $asw != 'n' ]
	do
		read -p "Les flags suivant vous conviennent ils? $flg [o/n]: " asw
	done
	if [ $asw = 'n' ]
	then
		read -p "Vos flags: " flg
	fi
    echo "CFLAGS\t+=\t$flg" >> $1
    echo "" >> $1
}

addSrc ()
{
	paths=$(pwd)
	asw="0"
	while [ $asw != 'o' ] && [ $asw != 'n' ]
	do
		read -p "Les sources sont elles ici: $paths [o/n]: " asw
	done
    if [ $asw = "n" ]
    then
		asw="0"
		while [ $asw = "0" ]
		do
			read -e -p "Quel est le chemin du dossier source (NE PAS UTILISER ~/)? " asw
			if [ $asw ] && [ -d $asw ]
			then
				asw=$(cd $asw && pwd)
			else
				echo "Le dossier $asw specifier n'existe pas."
				asw="0"
			fi
		done
		paths=$asw
    fi
	tabpaths=( ${tabpaths[*]} $paths )
	src=$(find $paths -maxdepth 1 -name "*.c" | rev | cut -d '/' -f1 | rev)
	echo "SRC$2\t\t=\t$src" | tr '\n' ' ' | sed "s/.$//" >> $1
	echo "" >> $1
	echo "" >> $1
	echo "SRCPATH$2\t=\t$paths" >> $1
	echo "" >> $1
	echo "SOURCES$2\t=\t\$(addprefix \$(SRCPATH$2)/, \$(SRC$2))" >> $1
	echo "" >> $1
}

addHdr ()
{
	asw="0"
	pathh=${tabpaths[$2]}
	while [ $asw != 'o' ] && [ $asw != 'n' ]
	do
		read -p "Les headers sont ils ici: $pathh [o/n]: " asw
	done
    if [ $asw = "n" ]
    then
		asw="0"
		while [ $asw = "0" ]
		do
			read -e -p "Quel est le chemin du dossier header (NE PAS UTILISER ~/)? " asw
			if [ $asw ] && [ -d $asw ]
			then
				asw=$(cd $asw && pwd)
			else
				echo "Le dossier $asw specifier n'existe pas."
				asw="0"
			fi
		done
		pathh=$asw
	fi
	tabpathh=( ${tabpathh[*]} $pathh )
	hdr=$(find $pathh -maxdepth 1 -name "*.h" | rev | cut -d '/' -f1 | rev)
	echo "HDR$2\t\t=\t$hdr" | tr '\n' ' ' | sed "s/.$//" >> $1
	echo "" >> $1
	echo "" >> $1
	echo "HDRPATH$2\t=\t$pathh" >> $1
	echo "" >> $1
	echo "HEADERS$2\t=\t\$(addprefix \$(HDRPATH$2)/, \$(HDR$2))" >> $1
	echo "" >> $1
}

addLib ()
{
	asw="0"
	pathl=""
	libname=""
	while [ $asw != 'o' ] && [ $asw != 'n' ]
	do
		read -p "Voulez vous ajouter une librairie? [o/n] " asw
	done
	if [ $asw = 'o' ]
	then
		asw="0"
		read -p "Quel est le nom de cette librairie (sans 'lib' ni '.a')? " asw
		libname=$asw
		echo "LIBNAME\t=\t$libname" >> $1
		echo "" >> $1
		asw="0"
		while [ $asw = "0" ]
		do
			read -e -p "Quel est le chemin vers votre librairie (NE PAS UTILISER ~/)? " asw
			if [ $asw ] && [ -d $asw ]
			then
				asw=$(cd $asw && pwd)
			else
				echo "Le dossier $asw specifier n'existe pas."
				asw="0"
			fi
		done
		pathl=$asw
		echo "LIBPATH\t=\t$pathl" >> $1
		echo "" >> $1
		asw="0"
		while [ $asw = "0" ]
		do
			read -e -p "Ou sont les headers de votre librairie (NE PAS UTILISER ~/)? " asw
			if [ $asw ] && [ -d $asw ]
			then
				asw=$(cd $asw && pwd)
			else
				echo "Le dossier $asw specifier n'existe pas."
				asw="0"
			fi
		done
		pathlh=$asw
		echo "LIBHEAD\t=\t$pathlh" >> $1
		echo "" >> $1
	fi
}

basics ()
{
	count=0
	tabobj=()
	tabsrcpath=()
	while [ $count -lt ${#tabpaths[@]} ]
	do
		echo "OBJ$count\t\t=\t\$(SRC$count:.c=.o)" >> $1
		echo "" >> $1
		tabobj=( ${tabobj[*]} "\$(OBJ$count)" )

		echo "%.o:\t\t\$(SRCPATH$count)/%.c" >> $1
		echo "\t\t\t\$(CC) -o \$@ -c \$^ \$(CFLAGS)" >> $1
		echo "" >> $1

		(( count++ ))
	done

    echo ".PHONY:\t\tall clean fclean re" >> $1
    echo "" >> $1

    echo "all:\t\t\$(NAME)" >> $1
    echo "" >> $1

    echo "\$(NAME):\t${tabobj[*]}" >> $1
	if [ $pathl != "" ]
	then
		echo "\t\t\t@(cd \$(LIBPATH) && \$(MAKE))" >> $1
		echo "\t\t\t\$(CC) -o \$(NAME) ${tabobj[*]} -I \$(LIBHEAD) -L \$(LIBPATH) -l\$(LIBNAME)" >> $1
	else
		echo "\t\t\t\$(CC) -o \$(NAME) ${tabobj[*]}" >> $1
	fi
    echo "" >> $1

    echo "clean:" >> $1
	if [ $pathl != "" ]
	then
		echo "\t\t\t@(cd \$(LIBPATH) && \$(MAKE) clean)" >> $1
	fi
	echo "\t\t\trm -rf ${tabobj[*]}" >> $1
    echo "" >> $1

    echo "fclean:\t\tclean" >> $1
    echo "\t\t\trm -rf \$(NAME)" >> $1
    echo "" >> $1

    echo "re:\t\t\tfclean all" >> $1
}

makefilecreation ()
{
	createheader $1

	addName $1

	addCompilo $1

	addFlags $1
	# Modification: tentative de multi Dossier
	count=0
	asw="0"
	tabpaths=( )
	addSrc $1 $count
	(( count++ ))
	while [ $asw != 'n' ]
	do
		read -p "Avez vous d'autres SOURCES? [o/n]: " asw
		if [ $asw = 'o' ]
		then
			addSrc $1 $count
			(( count++ ))
			asw="0"
		fi
	done

	count=0
	asw="0"
	tabpathh=( "" )
	addHdr $1 $count
	(( count++ ))
	while [ $asw != 'n' ]
	do
		read -p "Avez vous d'autres HEADERS? [o/n]: " asw
		if [ $asw = 'o' ]
		then
			addHdr $1 $count
			(( count++ ))
			asw="0"
		fi
	done

	addLib $1

	basics $1
}

if [ $# = 0 ]
then
	clear
    if [ -f Makefile ]
    then
		asw="0"
		while [ $asw != 'o' ] && [ $asw != 'n' ]
		do
			read -p "Un ficher Makefile existe deja, souhaitez vous le reecrire? [o/n]: " asw
		done
		if [ $asw = "o" ]
		then
			makefilecreation Makefile
			clear
			cat Makefile
		fi
    else
		touch Makefile
		makefilecreation Makefile
		clear
		cat Makefile
    fi
else
	echo Usage: ./createmakefile
fi
