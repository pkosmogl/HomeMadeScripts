# Bad yoda finder
Some times the output of some MC rivet routines contain badly weighted events.  
The cause of this has not yet been pinpointed. Those events cause weird behavior  
in the output distributions in specific bins. For those bins the errors are usually  
very large.  

Though we do not yet know the origin of this problem, we have seen it manifest in the  
output yoda files of Herwig++ and Powheg + Herwig++, as occasional very high values  
in the `sumw2` column.

We want to pinpoint the yoda files for which we get these huge values of `sumw2`.  
`badYODAfinder.sh` in L15 searches only for a particular line inside the yoda files  
at a time. A line inside the yoda files translates to a particular bin.  
So one should look at the distributions and inspect only the suspicious bins (lines).  
Half of the script is originally commented, because you want to first print all `sumw2`  
values for a given bin and see if you have the same order of magnitude for all yoda files.  
If you see large values (>= 3 orders of magnitude) compared to the general trend, then you  
adjust the if statement in L19 to pinpoint and "detect" only the suspicious yoda files.  
So once you get a feeling for what a suscpicious `sumw2` value is for a given bin, then  
you should uncomment L19-L21 and pinpoint those yoda files.

Once you pinpoint them, you can remove them by hand.  

***WARNING!!!***  
Always have back-up of the output files.  
Mistakes can happen and you will have to re-run your jobs.  
Also make sure that you consistently check back at your distributions to make sure that  
the bin in question is fixed after removing some yoda files, because at some point you  
might suffer from lack of statistic, as removing yoda files greatly reduces you overall  
number of events.
