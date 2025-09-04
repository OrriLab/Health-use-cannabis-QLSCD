* Note, line 36-40 and its iterations have been changed, previously if (e(rc)) != 0, now if (e(rc)) == 0. Need to take a further look at this, but this solves a problem of missing estimations.
* line 28 edited out

capture program drop auto_traj_final
program auto_traj_final, rclass
	version 15.0
		syntax , trajopts(string) [random(string) substantive(string)]
		
		* error checks
		if "`random'" != "" & "`substantive'" != ""	{
			di as error "must choose {bf:random} or {bf:substantive}"
			exit 198
		}
		if "`random'" == "" & "`substantive'" == ""	{
			di as error "options {bf:random} or {bf:substantive} are required"
			exit 198
		}
		
		* run estimations for `random'
		if "`random'" != ""	{
			quietly	{
				randopt , `random'
				return list
				local polynom `r(polynom)'
				local groups `r(groups)'
				local nseed `r(nseed)'
				local maxmod `r(maxmod)'
				*traj, `trajopts' order(0)
				mata: mattest = J(`=`=`polynom'+1'^`groups'',`=4+`groups'',.)
				local i 1
					forvalues j = 0/`polynom'	{
						if `groups' == 1	{
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`j')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: mattest[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
								}
							if `warning' != 0	{
								mata: mattest[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
								}
							else	{
								mata: mattest[`i',1]= st_numscalar("e(numGroups1)")
								mata: mattest[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: mattest[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								mata: mattest[`i',5]= `j'
								if `i' == `=`=`polynom'+1'^`groups''	{
									mata: mattest[.,3]= exp(mattest[.,2] :- colmax(mattest)[1,2]) :/ colsum(exp(mattest[.,2] :- colmax(mattest)[1,2]))
								}
							}
							local `++i'
						}
						else	{
							forvalues k = 0/`polynom'	{
								if `groups' == 2	{
									log using templog, replace
									capture noisily quietly traj, `trajopts' order(`j' `k')
									log close
									local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
									if (e(rc))== 0	{
										mata: mattest[`i',1]= st_numscalar("e(numGroups1)")
										local `++i'
										continue
										}
									if `warning' != 0	{
										mata: mattest[`i',1]= st_numscalar("e(numGroups1)")
										local `++i'
										continue
										}
									else	{
										mata: mattest[`i',1]= st_numscalar("e(numGroups1)")
										mata: mattest[`i',2]= st_numscalar("e(BIC_n_subjects)")
										mata: mattest[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
										mata: mattest[`i',5]= `j'
										mata: mattest[`i',6]= `k'
										if `i' == `=`=`polynom'+1'^`groups''	{
											mata: mattest[.,3]= exp(mattest[.,2] :- colmax(mattest)[1,2]) :/ colsum(exp(mattest[.,2] :- colmax(mattest)[1,2]))
											}
										}
									local `++i'
									}
								else	{
									forvalues l = 0/`polynom'	{
										if `groups' == 3	{
											mata: mattest[`i',5] = `j'
											mata: mattest[`i',6] = `k'
											mata: mattest[`i',7] = `l'
											if `i' == `=`=`polynom'+1'^`groups''	{
												mata: rseed(strtoreal(st_local("nseed")))
												mata randp = jumble(mattest)[(1..`maxmod'),.]
												forvalues u = 1/`maxmod' {
													mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7]))
													log using templog, replace
													capture noisily quietly traj, `trajopts' order(`norder')
													log close
													local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
													*if (e(rc))== 0	{
													*	mata: randp[`u',1]= st_numscalar("e(numGroups1)")
													*	local `++u'
													*	continue
													*	}
													if `warning' != 0	{
														mata: randp[`u',1]= st_numscalar("e(numGroups1)")
														local `++u'
														continue
														}
													else	{
														traj, `trajopts' order(`norder')
														mata: randp[`u',1]= st_numscalar("e(numGroups1)")
														mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
														mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
														if `u' == `maxmod'	{
															mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
															}
														}
													}
												}
											local `++i'
											}
										else	{
											forvalues m = 0/`polynom'	{
												if `groups' == 4	{
													mata: mattest[`i',5] = `j'
													mata: mattest[`i',6] = `k'
													mata: mattest[`i',7] = `l'
													mata: mattest[`i',8] = `m'
													if `i' == `=`=`polynom'+1'^`groups''	{
														mata: rseed(strtoreal(st_local("nseed")))
														mata randp = jumble(mattest)[(1..`maxmod'),.]
														forvalues u = 1/`maxmod' {
															mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8]))
															log using templog, replace
															capture noisily quietly traj, `trajopts' order(`norder')
															log close
															local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
															if (e(rc))== 0	{
																mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																local `++u'
																continue
																}
															if `warning' != 0	{
																mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																local `++u'
																continue
																}
															else	{
																traj, `trajopts' order(`norder')
																mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																if `u' == `maxmod'	{
																	mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																	}
																}
															}
														}
													local `++i'
													}
												else	{
												forvalues n = 0/`polynom'	{
													if `groups' == 5	{
														mata: mattest[`i',5] = `j'
														mata: mattest[`i',6] = `k'
														mata: mattest[`i',7] = `l'
														mata: mattest[`i',8] = `m'
														mata: mattest[`i',9] = `n'
														if `i' == `=`=`polynom'+1'^`groups''	{
															mata: rseed(strtoreal(st_local("nseed")))
															mata randp = jumble(mattest)[(1..`maxmod'),.]
															forvalues u = 1/`maxmod' {
																mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8])+" "+strofreal(randp[`u',9]))
																log using templog, replace
																capture noisily quietly traj, `trajopts' order(`norder')
																log close
																local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
																if (e(rc))== 0	{
																	mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																	local `++u'
																	continue
																	}
																if `warning' != 0	{
																	mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																	local `++u'
																	continue
																	}
																else	{
																	traj, `trajopts' order(`norder')
																	mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																	mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																	mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																	if `u' == `maxmod'	{
																		mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																		}
																	}
																}
															}
														local `++i'
														}
													else	{
														forvalues o = 0/`polynom'	{
															if `groups' == 6	{
																mata: mattest[`i',5] = `j'
																mata: mattest[`i',6] = `k'
																mata: mattest[`i',7] = `l'
																mata: mattest[`i',8] = `m'
																mata: mattest[`i',9] = `n'
																mata: mattest[`i',10] = `o'
																if `i' == `=`=`polynom'+1'^`groups''	{
																	mata: rseed(strtoreal(st_local("nseed")))
																	mata randp = jumble(mattest)[(1..`maxmod'),.]
																	forvalues u = 1/`maxmod' {
																		mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8])+" "+strofreal(randp[`u',9])+" "+strofreal(randp[`u',10]))
																		log using templog, replace
																		capture noisily quietly traj, `trajopts' order(`norder')
																		log close
																		local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
																		if (e(rc))== 0	{
																			mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																			local `++u'
																			continue
																			}
																		if `warning' != 0	{
																			mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																			local `++u'
																			continue
																			}
																		else	{
																			traj, `trajopts' order(`norder')
																			mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																			mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																			mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																			if `u' == `maxmod'	{
																				mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																				}
																			}
																		}
																	}
																local `++i'
																}
															else	{
																forvalues p = 0/`polynom'	{
																	if `groups' == 7	{
																		mata: mattest[`i',5] = `j'
																		mata: mattest[`i',6] = `k'
																		mata: mattest[`i',7] = `l'
																		mata: mattest[`i',8] = `m'
																		mata: mattest[`i',9] = `n'
																		mata: mattest[`i',10] = `o'
																		mata: mattest[`i',11] = `p'
																		if `i' == `=`=`polynom'+1'^`groups''	{
																			mata: rseed(strtoreal(st_local("nseed")))
																			mata randp = jumble(mattest)[(1..`maxmod'),.]
																			forvalues u = 1/`maxmod' {
																				mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8])+" "+strofreal(randp[`u',9])+" "+strofreal(randp[`u',10])+" "+strofreal(randp[`u',11]))
																				log using templog, replace
																				capture noisily quietly traj, `trajopts' order(`norder')
																				log close
																				local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
																				if (e(rc))== 0	{
																					mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																					local `++u'
																					continue
																					}
																				if `warning' != 0	{
																					mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																					local `++u'
																					continue
																					}
																				else	{
																					traj, `trajopts' order(`norder')
																					mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																					mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																					mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																					if `u' == `maxmod'	{
																						mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																						}
																					}
																				}
																			}
																		local `++i'
																		}
																	else	{
																		forvalues q = 0/`polynom'	{
																			if `groups' == 8	{
																				mata: mattest[`i',5] = `j'
																				mata: mattest[`i',6] = `k'
																				mata: mattest[`i',7] = `l'
																				mata: mattest[`i',8] = `m'
																				mata: mattest[`i',9] = `n'
																				mata: mattest[`i',10] = `o'
																				mata: mattest[`i',11] = `p'
																				mata: mattest[`i',12] = `q'
																				if `i' == `=`=`polynom'+1'^`groups''	{
																					mata: rseed(strtoreal(st_local("nseed")))
																					mata randp = jumble(mattest)[(1..`maxmod'),.]
																					forvalues u = 1/`maxmod' {
																						mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8])+" "+strofreal(randp[`u',9])+" "+strofreal(randp[`u',10])+" "+strofreal(randp[`u',11])+" "+strofreal(randp[`u',12]))
																						log using templog, replace
																						capture noisily quietly traj, `trajopts' order(`norder')
																						log close
																						local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
																						if (e(rc))== 0	{
																							mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																							local `++u'
																							continue
																							}
																						if `warning' != 0	{
																							mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																							local `++u'
																							continue
																							}
																						else	{
																							traj, `trajopts' order(`norder')
																							mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																							mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																							mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																							if `u' == `maxmod'	{
																								mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																								}
																							}
																						}
																					}
																				local `++i'
																				}
																			else	{
																				forvalues r = 0/`polynom'	{
																					if `groups' == 9	{
																						mata: mattest[`i',5] = `j'
																						mata: mattest[`i',6] = `k'
																						mata: mattest[`i',7] = `l'
																						mata: mattest[`i',8] = `m'
																						mata: mattest[`i',9] = `n'
																						mata: mattest[`i',10] = `o'
																						mata: mattest[`i',11] = `p'
																						mata: mattest[`i',12] = `q'
																						mata: mattest[`i',13] = `r'
																						if `i' == `=`=`polynom'+1'^`groups''	{
																							mata: rseed(strtoreal(st_local("nseed")))
																							mata randp = jumble(mattest)[(1..`maxmod'),.]
																							forvalues u = 1/`maxmod' {
																								mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8])+" "+strofreal(randp[`u',9])+" "+strofreal(randp[`u',10])+" "+strofreal(randp[`u',11])+" "+strofreal(randp[`u',12])+" "+strofreal(randp[`u',13]))
																								log using templog, replace
																								capture noisily quietly traj, `trajopts' order(`norder')
																								log close
																								local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
																								if (e(rc))== 0	{
																									mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																									local `++u'
																									continue
																									}
																								if `warning' != 0	{
																									mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																									local `++u'
																									continue
																									}
																								else	{
																									traj, `trajopts' order(`norder')
																									mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																									mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																									mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																									if `u' == `maxmod'	{
																										mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																										}
																									}
																								}
																							}
																						local `++i'
																						}
																					else	{
																						forvalues s = 0/`polynom'	{
																							if `groups' == 10	{
																								mata: mattest[`i',5] = `j'
																								mata: mattest[`i',6] = `k'
																								mata: mattest[`i',7] = `l'
																								mata: mattest[`i',8] = `m'
																								mata: mattest[`i',9] = `n'
																								mata: mattest[`i',10] = `o'
																								mata: mattest[`i',11] = `p'
																								mata: mattest[`i',12] = `q'
																								mata: mattest[`i',13] = `r'
																								mata: mattest[`i',14] = `s'
																								if `i' == `=`=`polynom'+1'^`groups''	{
																									mata: rseed(strtoreal(st_local("nseed")))
																									mata randp = jumble(mattest)[(1..`maxmod'),.]
																									forvalues u = 1/`maxmod' {
																										mata: st_local("norder",strofreal(randp[`u',5])+" "+strofreal(randp[`u',6])+" "+strofreal(randp[`u',7])+" "+strofreal(randp[`u',8])+" "+strofreal(randp[`u',9])+" "+strofreal(randp[`u',10])+" "+strofreal(randp[`u',11])+" "+strofreal(randp[`u',12])+" "+strofreal(randp[`u',13])+" "+strofreal(randp[`u',14]))
																										log using templog, replace
																										capture noisily quietly traj, `trajopts' order(`norder')
																										log close
																										local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
																										if (e(rc))== 0	{
																											mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																											local `++u'
																											continue
																											}
																										if `warning' != 0	{
																											mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																											local `++u'
																											continue
																											}
																										else	{
																											traj, `trajopts' order(`norder')
																											mata: randp[`u',1]= st_numscalar("e(numGroups1)")
																											mata: randp[`u',2]= st_numscalar("e(BIC_n_subjects)")
																											mata: randp[`u',4]= (min(st_matrix("e(groupSize1)"))>5)
																											if `u' == `maxmod'	{
																												mata: randp[.,3]= exp(randp[.,2] :- colmax(randp)[1,2]) :/ colsum(exp(randp[.,2] :- colmax(randp)[1,2]))
																												}
																											}
																										}
																									}
																								local `++i'
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			if `groups' > 2	{
				mata: st_local("rows",strofreal(rows(randp)))
				if `rows' > 10	{
					mata final = sort(randp,-3)[1..10,.]
					mata: st_matrix("final", final)
				}
				else	{
					mata final = sort(randp,-3)
					mata: st_matrix("final", final)
				}
			}
			else if (`groups' == 2) & (`=`=`polynom'+1'^`groups'' > 10) {
				mata final = sort(mattest,-3)[1..10,.]
				mata: st_matrix("final", final)
			}
			else	{
				mata final = sort(mattest,-3)
				mata: st_matrix("final", final)
			}
			local colnames ""N Groups" "BIC subj." "P (corr.)" "Group n>5%""
			forval  j = 1/`groups' { 
			   local colnames "`colnames' p_`j'"
			}
			matrix colnames final = `colnames'
			matlist final, title({bf:BIC-based polynomial selection}) tindent(8) names(col) border(rows) left(4)
			di "	{bf:Notes.}"
			di "	{it:BIC subj.} = Sample size-based BIC."
			di "	{it:P (corr.)} = Probability correct model."
			di "	{it:Group n > 5%} = 0 if at least 1 group with less than 5% of subjects assigned; otherwise, 1."
			di "	{it:p_n} = polynomial order for group n."
			di "	{bf:`maxmod'} models have been tested."
			di "	{bf:Warning messages} may appear if iterations had convergence issues."
		}
		if "`substantive'" != ""	{
			quietly	{
				subsopt ,  `substantive'
				return list
				local order `r(order)'
				local nseed `r(nseed)'
				local maxmod `r(maxmod)'
				tokenize `order'
				local groups: word count `order'
				mata: add = J(`=3^`groups'',`groups',.)
				if `groups' == 1	{
					mata: model = J(`=3^`groups'',1,(`1'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						mata: add[`i',1]= `j'
						local `++i'
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4))
					mata: totest = sort(totest,3)
					mata: st_local("rows",strofreal(rows(totest)))
					mata: stats = J(`rows',4,.)
					local i 1
					forvalues j = 1/`rows'	{
						mata: st_local("o1",strofreal(totest[`j',1]))
						log using "`c(tmpdir)'\templog.smcl", replace
						capture noisily quietly traj, `trajopts' order(`j')
						log close
						local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
						if (e(rc))== 0	{
							mata: stats[`i',1]= st_numscalar("e(numGroups1)")
							local `++i'
							continue
						}
						if `warning' != 0	{
							mata: stats[`i',1]= st_numscalar("e(numGroups1)")
							local `++i'
							continue
						}
						else	{
							mata: stats[`i',1]= st_numscalar("e(numGroups1)")
							mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
							mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
							if `i' == `rows'	{
								mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
							}
						}
						local `++i'
					}
				}
				if `groups' == 2	{
					mata: model = J(`=3^`groups'',1,(`1',`2'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							mata: add[`i',1]= `j'
							mata: add[`i',2]= `k'
							local `++i'
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4))
					mata: totest = sort(totest,4)
					mata: st_local("rows",strofreal(rows(totest)))
					mata: stats = J(`rows',4,.)
					local i 1
					forvalues j = 1/`rows'	{
						mata: st_local("o1",strofreal(totest[`j',1]))
						mata: st_local("o2",strofreal(totest[`j',2]))
						log using "`c(tmpdir)'\templog.smcl", replace
						capture noisily quietly traj, `trajopts' order(`o1' `o2')
						log close
						local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
						if (e(rc))== 0	{
							mata: stats[`i',1]= st_numscalar("e(numGroups1)")
							local `++i'
							continue
						}
						if `warning' != 0	{
							mata: stats[`i',1]= st_numscalar("e(numGroups1)")
							local `++i'
							continue
						}
						else	{
							mata: stats[`i',1]= st_numscalar("e(numGroups1)")
							mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
							mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
							if `i' == `rows'	{
								mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
							}
						}
						local `++i'
					}
				}
				if `groups' == 3	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								mata: add[`i',1]= `j'
								mata: add[`i',2]= `k'
								mata: add[`i',3]= `l'
								local `++i'
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4))
					mata: totest = sort(totest,5)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 4	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									mata: add[`i',1]= `j'
									mata: add[`i',2]= `k'
									mata: add[`i',3]= `l'
									mata: add[`i',4]= `m'
									local `++i'
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4))
					mata: totest = sort(totest,6)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 5	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									forvalues n = -1/1	{
										mata: add[`i',1]= `j'
										mata: add[`i',2]= `k'
										mata: add[`i',3]= `l'
										mata: add[`i',4]= `m'
										mata: add[`i',5]= `n'
										local `++i'
									}
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4))
					mata: totest = sort(totest,7)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 6	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									forvalues n = -1/1	{
										forvalues o = -1/1	{
											mata: add[`i',1]= `j'
											mata: add[`i',2]= `k'
											mata: add[`i',3]= `l'
											mata: add[`i',4]= `m'
											mata: add[`i',5]= `n'
											mata: add[`i',6]= `o'
											local `++i'
										}
									}
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4))
					mata: totest = sort(totest,8)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 7	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									forvalues n = -1/1	{
										forvalues o = -1/1	{
											forvalues p = -1/1	{
												mata: add[`i',1]= `j'
												mata: add[`i',2]= `k'
												mata: add[`i',3]= `l'
												mata: add[`i',4]= `m'
												mata: add[`i',5]= `n'
												mata: add[`i',6]= `o'
												mata: add[`i',7]= `p'
												local `++i'
											}
										}
									}
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4))
					mata: totest = sort(totest,9)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 8	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7',`8'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									forvalues n = -1/1	{
										forvalues o = -1/1	{
											forvalues p = -1/1	{
												forvalues q = -1/1	{
													mata: add[`i',1]= `j'
													mata: add[`i',2]= `k'
													mata: add[`i',3]= `l'
													mata: add[`i',4]= `m'
													mata: add[`i',5]= `n'
													mata: add[`i',6]= `o'
													mata: add[`i',7]= `p'
													mata: add[`i',8]= `q'
													local `++i'
												}
											}
										}
									}
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4) :& (totest[,8] :>= 0) :& (totest[,8] :< 4))
					mata: totest = sort(totest,10)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							mata: st_local("o8",strofreal(totest[`j',8]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7' `o8')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							mata: st_local("o8",strofreal(totest[`j',8]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7' `o8')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 9	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7',`8',`9'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									forvalues n = -1/1	{
										forvalues o = -1/1	{
											forvalues p = -1/1	{
												forvalues q = -1/1	{
													forvalues r = -1/1	{
														mata: add[`i',1]= `j'
														mata: add[`i',2]= `k'
														mata: add[`i',3]= `l'
														mata: add[`i',4]= `m'
														mata: add[`i',5]= `n'
														mata: add[`i',6]= `o'
														mata: add[`i',7]= `p'
														mata: add[`i',8]= `q'
														mata: add[`i',9]= `r'
														local `++i'
													}
												}
											}
										}
									}
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4) :& (totest[,8] :>= 0) :& (totest[,8] :< 4) :& (totest[,9] :>= 0) :& (totest[,9] :< 4))
					mata: totest = sort(totest,11)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							mata: st_local("o8",strofreal(totest[`j',8]))
							mata: st_local("o9",strofreal(totest[`j',9]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7' `o8' `o9')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							mata: st_local("o8",strofreal(totest[`j',8]))
							mata: st_local("o9",strofreal(totest[`j',9]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7' `o8' `o9')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
				if `groups' == 10	{
					mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7',`8',`9',`10'))
					mata: id = J(`=3^`groups'',2,.)
					mata: id[ceil(`=(3^`groups')/2'),2] = 1
					local i 1
					forvalues j = -1/1	{
						forvalues k = -1/1	{
							forvalues l = -1/1	{
								forvalues m = -1/1	{
									forvalues n = -1/1	{
										forvalues o = -1/1	{
											forvalues p = -1/1	{
												forvalues q = -1/1	{
													forvalues r = -1/1	{
														forvalues s = -1/1	{
															mata: add[`i',1]= `j'
															mata: add[`i',2]= `k'
															mata: add[`i',3]= `l'
															mata: add[`i',4]= `m'
															mata: add[`i',5]= `n'
															mata: add[`i',6]= `o'
															mata: add[`i',7]= `p'
															mata: add[`i',8]= `q'
															mata: add[`i',9]= `r'
															mata: add[`i',10]= `s'
															local `++i'
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
					mata: totest = (model+add),id
					mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4) :& (totest[,8] :>= 0) :& (totest[,8] :< 4) :& (totest[,9] :>= 0) :& (totest[,9] :< 4) :& (totest[,10] :>= 0) :& (totest[,10] :< 4))
					mata: totest = sort(totest,11)
					mata: st_local("rows",strofreal(rows(totest)))
					if "`maxmod'" != "all"	{
						mata: model = totest[(1),.]
						mata: randp = totest[(2..`rows'),.]
						mata: rseed(strtoreal(st_local("nseed")))
						capture mata: randp = jumble(randp)[(1..`=`maxmod'-1'),.]
						if _rc == 3301	{
							mata: sum = model\randp
							mata: st_local("errows",strofreal(rows(sum)))
							di as error "{bf:maxmod()} must not be higher than {bf:`errows'}"
							exit 3301
						}
						mata: totest = model\randp
						mata: stats = J(`maxmod',4,.)
						local i 1
						forvalues j = 1/`maxmod'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							mata: st_local("o8",strofreal(totest[`j',8]))
							mata: st_local("o9",strofreal(totest[`j',9]))
							mata: st_local("o10",strofreal(totest[`j',10]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7' `o8' `o9' `o10')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `maxmod'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
					else	{
						mata: stats = J(`rows',4,.)
						local i 1
						forvalues j = 1/`rows'	{
							mata: st_local("o1",strofreal(totest[`j',1]))
							mata: st_local("o2",strofreal(totest[`j',2]))
							mata: st_local("o3",strofreal(totest[`j',3]))
							mata: st_local("o4",strofreal(totest[`j',4]))
							mata: st_local("o5",strofreal(totest[`j',5]))
							mata: st_local("o6",strofreal(totest[`j',6]))
							mata: st_local("o7",strofreal(totest[`j',7]))
							mata: st_local("o8",strofreal(totest[`j',8]))
							mata: st_local("o9",strofreal(totest[`j',9]))
							mata: st_local("o10",strofreal(totest[`j',10]))
							log using "`c(tmpdir)'\templog.smcl", replace
							capture noisily quietly traj, `trajopts' order(`o1' `o2' `o3' `o4' `o5' `o6' `o7' `o8' `o9' `o10')
							log close
							local warning = strpos(fileread("`c(tmpdir)'\templog.smcl"), "Warning") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "WARNING") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "Unable to calculate") | strpos(fileread("`c(tmpdir)'\templog.smcl"), "warning")
							if (e(rc))== 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							if `warning' != 0	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								local `++i'
								continue
							}
							else	{
								mata: stats[`i',1]= st_numscalar("e(numGroups1)")
								mata: stats[`i',2]= st_numscalar("e(BIC_n_subjects)")
								mata: stats[`i',4]= (min(st_matrix("e(groupSize1)"))>5)
								if `i' == `rows'	{
									mata: stats[.,3]= exp(stats[.,2] :- colmax(stats)[1,2]) :/ colsum(exp(stats[.,2] :- colmax(stats)[1,2]))
								}
							}
							local `++i'
						}
					}
				}
			}
			mata: totest = totest[.,(1..`groups')]
			mata: final = (stats,totest)
			mata: st_local("rows",strofreal(rows(final)))
			mata: model = final[(1),.]
			mata: rest = final[(2..`rows'),.]
			mata: rest = sort(rest,-3)
			mata: final = (model\rest)
			if `rows' < 11	{
				mata: st_matrix("final", final)
			}
			else	{
				mata: final = final[1..10,.]
				mata: st_matrix("final", final)
			}
			local colnames ""N Groups" "BIC subj." "P (corr.)" "Group n>5%""
			forval  j = 1/`groups' {
				local colnames "`colnames' p_`j'"
			}
			matrix colnames final = `colnames'
			matlist final, title({bf:BIC-based polynomial selection}) tindent(8) names(col) border(rows) left(4)
			di "	{bf:Notes.}"
			if final[1,3] > final[2,3]	{
				di "	{bf:The proposed model has the best BIC value of all the models tested}"
			}
			else	{
				di "	{bf:The proposed model might not have the best BIC value of all the models tested}"
			}
			di "	{it:BIC subj.} = Sample size-based BIC."
			di "	{it:P (corr.)} = Probability correct model."
			di "	{it:Group n > 5%} = 0 if at least 1 group with less than 5% of subjects assigned; otherwise, 1."
			di "	{it:p_n} = polynomial order for group n."
			di "	{bf:`rows'} models have been tested."
			di "	{bf:Warning messages} may appear if iterations had convergence issues."
		}
end

capture program drop randopt
program randopt, rclass
	version 15.0
	syntax , groups(numlist integer min=1 max=1 >=1 <=10) polynom(numlist integer min=1 max=1 >=0 <=3) [nseed(integer 1234) maxmod(string)]
	if "`maxmod'" != ""	{
		if "`maxmod'" != "all"	{
			capture confirm integer number `maxmod'
			if _rc	{
				di as error "{bf:maxmod()} must be {bf:all} or an integer higher than zero"
				error 198
			}
			if `maxmod' < 1	{
				di as error "{bf:maxmod()} must be {bf:all} or an integer higher than zero"
				error 198
			}
			if `maxmod' > `=`=`polynom'+1'^`groups''	{
				di as error "{bf:maxmod()} must not be higher than {bf:all} possible models (`=`=`polynom'+1'^`groups'')"
			}
		}
	}
	if "`maxmod'" == ""	{
		if `=`=`polynom'+1'^`groups'' > 32	{
			return local maxmod "32"
		}
		else	{
			return local maxmod "`=`=`polynom'+1'^`groups''"
		}
	}
	if `groups' <3 & "`maxmod'" != ""	{
		di as error "{bf:groups()} are less than 3, {bf:maxmod()} will not be used"
	}
	if `groups' >2 & "`maxmod'" != ""	{
		if "`maxmod'" == "all"	{
			return local maxmod "`=`=`polynom'+1'^`groups''"
		}
		else	{
			return local maxmod "`maxmod'"
		}
	}
	return local groups "`groups'"
	return local polynom "`polynom'"
	return local nseed "`nseed'"
end

capture program drop subsopt
program subsopt, rclass
	version 15.0
	syntax , order(numlist integer min=1 max=10 >=0 <=3) [nseed(integer 1234) maxmod(string)]
	if "`maxmod'" != ""	{
		if "`maxmod'" != "all"	{
			capture confirm integer number `maxmod'
			if _rc	{
				di as error "{bf:maxmod()} must be {bf:all} or an integer higher than zero"
				error 198
			}
			if `maxmod' < 1	{
				di as error "{bf:maxmod()} must be {bf:all} or an integer higher than zero"
				error 198
			}
		}
	}
	return local order "`order'"
	tokenize `order'
	local groups: word count `order'	
	mata: add = J(`=3^`groups'',`groups',.)
	if `groups' == 1	{
		mata: model = J(`=3^`groups'',1,(`1'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			mata: add[`i',1]= `j'
			local `++i'
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4))
		mata: totest = sort(totest,3)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 2	{
		mata: model = J(`=3^`groups'',1,(`1',`2'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				mata: add[`i',1]= `j'
				mata: add[`i',2]= `k'
				local `++i'
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4))
		mata: totest = sort(totest,4)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 3	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					mata: add[`i',1]= `j'
					mata: add[`i',2]= `k'
					mata: add[`i',3]= `l'
					local `++i'
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4))
		mata: totest = sort(totest,5)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 4	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						mata: add[`i',1]= `j'
						mata: add[`i',2]= `k'
						mata: add[`i',3]= `l'
						mata: add[`i',4]= `m'
						local `++i'
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4))
		mata: totest = sort(totest,6)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 5	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						forvalues n = -1/1	{
							mata: add[`i',1]= `j'
							mata: add[`i',2]= `k'
							mata: add[`i',3]= `l'
							mata: add[`i',4]= `m'
							mata: add[`i',5]= `n'
							local `++i'
						}
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4))
		mata: totest = sort(totest,7)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 6	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						forvalues n = -1/1	{
							forvalues o = -1/1	{
								mata: add[`i',1]= `j'
								mata: add[`i',2]= `k'
								mata: add[`i',3]= `l'
								mata: add[`i',4]= `m'
								mata: add[`i',5]= `n'
								mata: add[`i',6]= `o'
								local `++i'
							}
						}
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4))
		mata: totest = sort(totest,8)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 7	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						forvalues n = -1/1	{
							forvalues o = -1/1	{
								forvalues p = -1/1	{
									mata: add[`i',1]= `j'
									mata: add[`i',2]= `k'
									mata: add[`i',3]= `l'
									mata: add[`i',4]= `m'
									mata: add[`i',5]= `n'
									mata: add[`i',6]= `o'
									mata: add[`i',7]= `p'
									local `++i'
								}
							}
						}
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4))
		mata: totest = sort(totest,9)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 8	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7',`8'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						forvalues n = -1/1	{
							forvalues o = -1/1	{
								forvalues p = -1/1	{
									forvalues q = -1/1	{
										mata: add[`i',1]= `j'
										mata: add[`i',2]= `k'
										mata: add[`i',3]= `l'
										mata: add[`i',4]= `m'
										mata: add[`i',5]= `n'
										mata: add[`i',6]= `o'
										mata: add[`i',7]= `p'
										mata: add[`i',8]= `q'
										local `++i'
									}
								}
							}
						}
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4) :& (totest[,8] :>= 0) :& (totest[,8] :< 4))
		mata: totest = sort(totest,10)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 9	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7',`8',`9'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						forvalues n = -1/1	{
							forvalues o = -1/1	{
								forvalues p = -1/1	{
									forvalues q = -1/1	{
										forvalues r = -1/1	{
											mata: add[`i',1]= `j'
											mata: add[`i',2]= `k'
											mata: add[`i',3]= `l'
											mata: add[`i',4]= `m'
											mata: add[`i',5]= `n'
											mata: add[`i',6]= `o'
											mata: add[`i',7]= `p'
											mata: add[`i',8]= `q'
											mata: add[`i',9]= `r'
											local `++i'
										}
									}
								}
							}
						}
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4) :& (totest[,8] :>= 0) :& (totest[,8] :< 4) :& (totest[,9] :>= 0) :& (totest[,9] :< 4))
		mata: totest = sort(totest,11)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' == 10	{
		mata: model = J(`=3^`groups'',1,(`1',`2',`3',`4',`5',`6',`7',`8',`9',`10'))
		mata: id = J(`=3^`groups'',2,.)
		mata: id[ceil(`=(3^`groups')/2'),2] = 1
		local i 1
		forvalues j = -1/1	{
			forvalues k = -1/1	{
				forvalues l = -1/1	{
					forvalues m = -1/1	{
						forvalues n = -1/1	{
							forvalues o = -1/1	{
								forvalues p = -1/1	{
									forvalues q = -1/1	{
										forvalues r = -1/1	{
											forvalues s = -1/1	{
												mata: add[`i',1]= `j'
												mata: add[`i',2]= `k'
												mata: add[`i',3]= `l'
												mata: add[`i',4]= `m'
												mata: add[`i',5]= `n'
												mata: add[`i',6]= `o'
												mata: add[`i',7]= `p'
												mata: add[`i',8]= `q'
												mata: add[`i',9]= `r'
												mata: add[`i',10]= `s'
												local `++i'
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		mata: totest = (model+add),id
		mata: totest = select(totest, (totest[,1] :>= 0) :& (totest[,1] :< 4) :& (totest[,2] :>= 0) :& (totest[,2] :< 4) :& (totest[,3] :>= 0) :& (totest[,3] :< 4) :& (totest[,4] :>= 0) :& (totest[,4] :< 4) :& (totest[,5] :>= 0) :& (totest[,5] :< 4) :& (totest[,6] :>= 0) :& (totest[,6] :< 4) :& (totest[,7] :>= 0) :& (totest[,7] :< 4) :& (totest[,8] :>= 0) :& (totest[,8] :< 4) :& (totest[,9] :>= 0) :& (totest[,9] :< 4) :& (totest[,10] :>= 0) :& (totest[,10] :< 4))
		mata: totest = sort(totest,11)
		mata: st_local("rows",strofreal(rows(totest)))
	}
	if `groups' <3 & "`maxmod'" != ""	{
		di as error "{bf:groups()} are less than 3, {bf:maxmod()} will not be used"
		return local maxmod `=`rows''
	}
	if `groups' >2	{
		if "`maxmod'" != "" & "`maxmod'" != "all"	{
			if `maxmod' > `rows'	{
				di as error "{bf:maxmod()} must not be higher than {bf:all} possible models (`=`rows'')"
				error 198
			}

			else	{
				return local maxmod "`maxmod'"
			}
		}
		if	"`maxmod'" == "all"	{
			return local maxmod `=`rows''
		}
		if "`maxmod'" == ""	{
			if `=`rows'' > 32	{
				return local maxmod "32"
			}
			else	{
				return local maxmod `=`rows''
			}
		}
	}
	return local nseed "`nseed'"
end
