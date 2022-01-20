
/*Udise tables*/

create table if not exists udise_nsqf_plcmnt_c12(
udise_sch_code  bigint not null,
ac_year  text,
sector_no  smallint not null,
item_id  smallint,
opt_plcmnt_b  smallint,
opt_plcmnt_g  smallint,
placed_b  smallint,
placed_g  smallint,
voc_hs_b  smallint,
voc_hs_g  smallint,
nonvoc_hs_b  smallint,
nonvoc_hs_g  smallint,
self_emp_b  smallint,
self_emp_g  smallint,
primary key(udise_sch_code,sector_no,item_id)
);

create table if not exists udise_nsqf_plcmnt_c10(
udise_sch_code  bigint not null,
ac_year  text,
sector_no  smallint not null,
item_id  smallint,
opt_plcmnt_b  smallint,
opt_plcmnt_g  smallint,
placed_b  smallint,
placed_g  smallint,
voc_hs_b  smallint,
voc_hs_g  smallint,
nonvoc_hs_b  smallint,
nonvoc_hs_g  smallint,
self_emp_b  smallint,
self_emp_g  smallint,
primary key(udise_sch_code,sector_no,item_id)
);

create table if not exists udise_nsqf_class_cond(
udise_sch_code  bigint not null,
ac_year  text,
sector_no  smallint not null,
class_type_id  smallint not null,
c9  smallint,
c10  smallint,
c11  smallint,
c12  smallint,
primary key(udise_sch_code,sector_no,class_type_id)
);

create table if not exists udise_sch_exmres_c12(
udise_sch_code  bigint not null,
ac_year  text,
item_id  smallint not null,
stream_id  smallint not null,
gen_app_b  smallint,
gen_app_g  smallint,
obc_app_b  smallint,
obc_app_g  smallint,
sc_app_b  smallint,
sc_app_g  smallint,
st_app_b  smallint,
st_app_g  smallint,
gen_pass_b  smallint,
gen_pass_g  smallint,
obc_pass_b  smallint,
obc_pass_g  smallint,
sc_pass_b  smallint,
sc_pass_g  smallint,
st_pass_b  smallint,
st_pass_g  smallint,
primary key(udise_sch_code,item_id,stream_id)
);

create table if not exists udise_sch_exmres_c10(
udise_sch_code  bigint not null,
ac_year  text,
item_id  smallint not null,
gen_app_b  smallint,
gen_app_g  smallint,
obc_app_b  smallint,
obc_app_g  smallint,
sc_app_b  smallint,
sc_app_g  smallint,
st_app_b  smallint,
st_app_g  smallint,
gen_pass_b  smallint,
gen_pass_g  smallint,
obc_pass_b  smallint,
obc_pass_g  smallint,
sc_pass_b  smallint,
sc_pass_g  smallint,
st_pass_b  smallint,
st_pass_g  smallint,
primary key(udise_sch_code,item_id)
);

create table if not exists udise_sch_exmres_c5(
udise_sch_code  bigint primary key not null,
ac_year  text,
gen_app_b  smallint,
gen_app_g  smallint,
obc_app_b  smallint,
obc_app_g  smallint,
sc_app_b  smallint,
sc_app_g  smallint,
st_app_b  smallint,
st_app_g  smallint,
gen_pass_b  smallint,
gen_pass_g  smallint,
obc_pass_b  smallint,
obc_pass_g  smallint,
sc_pass_b  smallint,
sc_pass_g  smallint,
st_pass_b  smallint,
st_pass_g  smallint,
gen_60p_b  smallint,
gen_60p_g  smallint,
obc_60p_b  smallint,
obc_60p_g  smallint,
sc_60p_b  smallint,
sc_60p_g  smallint,
st_60p_b  smallint,
st_60p_g  smallint
);

create table if not exists udise_sch_incen_cwsn(
udise_sch_code  bigint not null,
ac_year  text,
item_id  smallint not null,
tot_pre_pri_b  smallint,
tot_pre_pri_g  smallint,
tot_pry_b  smallint,
tot_pry_g  smallint,
tot_upr_b  smallint,
tot_upr_g  smallint,
tot_sec_b  smallint,
tot_sec_g  smallint,
tot_hsec_b  smallint,
tot_hsec_g  smallint,
primary key(udise_sch_code,item_id)
);

create table if not exists udise_sch_incentives(
udise_sch_code  bigint not null,
ac_year  text,
grade_pri_upr  smallint not null,
incentive_type  smallint not null,
gen_b  smallint,
gen_g  smallint,
sc_b  smallint,
sc_g  smallint,
st_b  smallint,
st_g  smallint,
obc_b  smallint,
obc_g  smallint,
min_muslim_b  smallint,
min_muslim_g  smallint,
min_oth_b  smallint,
min_oth_g  smallint,
primary key(udise_sch_code,grade_pri_upr,incentive_type)
);

create table if not exists udise_sch_enr_by_stream(
udise_sch_code  bigint not null,
ac_year  text,
stream_id  smallint not null,
caste_id  smallint not null,
ec11_b  smallint,
ec11_g  smallint,
ec12_b  smallint,
ec12_g  smallint,
rc11_b  smallint,
rc11_g  smallint,
rc12_b  smallint,
rc12_g  smallint,
primary key(udise_sch_code,stream_id,caste_id)
);

create table if not exists udise_sch_enr_cwsn(
udise_sch_code  bigint not null,
ac_year  text,
disability_type  smallint not null,
cpp_b  smallint,
cpp_g  smallint,
c1_b  smallint,
c1_g  smallint,
c2_b  smallint,
c2_g  smallint,
c3_b  smallint,
c3_g  smallint,
c4_b  smallint,
c4_g  smallint,
c5_b  smallint,
c5_g  smallint,
c6_b  smallint,
c6_g  smallint,
c7_b  smallint,
c7_g  smallint,
c8_b  smallint,
c8_g  smallint,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
c12_b  smallint,
c12_g  smallint,
primary key(udise_sch_code,disability_type)
);

create table if not exists udise_sch_enr_medinstr(
udise_sch_code  bigint not null,
ac_year  text,
medinstr_seq  smallint not null,
c1_b  smallint,
c1_g  smallint,
c2_b  smallint,
c2_g  smallint,
c3_b  smallint,
c3_g  smallint,
c4_b  smallint,
c4_g  smallint,
c5_b  smallint,
c5_g  smallint,
c6_b  smallint,
c6_g  smallint,
c7_b  smallint,
c7_g  smallint,
c8_b  smallint,
c8_g  smallint,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
primary key(udise_sch_code,medinstr_seq)
);

create table if not exists udise_sch_enr_age(
udise_sch_code  bigint not null,
ac_year  text,
age_id  smallint not null,
c1_b  smallint,
c1_g  smallint,
c2_b  smallint,
c2_g  smallint,
c3_b  smallint,
c3_g  smallint,
c4_b  smallint,
c4_g  smallint,
c5_b  smallint,
c5_g  smallint,
c6_b  smallint,
c6_g  smallint,
c7_b  smallint,
c7_g  smallint,
c8_b  smallint,
c8_g  smallint,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
c12_b  smallint,
c12_g  smallint,
primary key(udise_sch_code,age_id)
);

create table if not exists udise_sch_enr_reptr(
udise_sch_code  bigint not null,
ac_year  text,
item_group  smallint not null,
item_id  smallint not null,
c1_b  smallint,
c1_g  smallint,
c2_b  smallint,
c2_g  smallint,
c3_b  smallint,
c3_g  smallint,
c4_b  smallint,
c4_g  smallint,
c5_b  smallint,
c5_g  smallint,
c6_b  smallint,
c6_g  smallint,
c7_b  smallint,
c7_g  smallint,
c8_b  smallint,
c8_g  smallint,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
c12_b  smallint,
c12_g  smallint,
primary key(udise_sch_code,item_group,item_id)
);

create table if not exists udise_sch_enr_fresh(
udise_sch_code  bigint not null,
ac_year  text,
item_group  smallint not null,
item_id  smallint not null,
cpp_b  smallint,
cpp_g  smallint,
c1_b  smallint,
c1_g  smallint,
c2_b  smallint,
c2_g  smallint,
c3_b  smallint,
c3_g  smallint,
c4_b  smallint,
c4_g  smallint,
c5_b  smallint,
c5_g  smallint,
c6_b  smallint,
c6_g  smallint,
c7_b  smallint,
c7_g  smallint,
c8_b  smallint,
c8_g  smallint,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
c12_b  smallint,
c12_g  smallint,
primary key(udise_sch_code,item_group,item_id)
);

create table if not exists udise_sch_enr_newadm(
udise_sch_code  bigint primary key not null,
ac_year  text,
age4_b  smallint,
age4_g  smallint,
age5_b  smallint,
age5_g  smallint,
age6_b  smallint,
age6_g  smallint,
age7_b  smallint,
age7_g  smallint,
age8_b  smallint,
age8_g  smallint,
same_sch_b  smallint,
same_sch_g  smallint,
oth_sch_b  smallint,
oth_sch_g  smallint,
anganwadi_b  smallint,
anganwadi_g  smallint
);

create table if not exists udise_sch_facility(
udise_sch_code  bigint primary key not null,
ac_year  text,
bld_status  smallint,
bld_blk_tot  smallint,
bld_blk  smallint,
bld_blk_ppu  smallint,
bld_blk_kuc  smallint,
bld_blk_tnt  smallint,
bld_blk_dptd  smallint,
bld_blk_undcons  smallint,
bndrywall_type  smallint,
clsrms_inst  smallint,
clsrms_und_cons  smallint,
clsrms_dptd  smallint,
clsrms_pre_pri  smallint,
clsrms_pri  smallint,
clsrms_upr  smallint,
clsrms_sec  smallint,
clsrms_hsec  smallint,
othrooms  smallint,
clsrms_gd  smallint,
clsrms_gd_ppu  smallint,
clsrms_gd_kuc  smallint,
clsrms_gd_tnt  smallint,
clsrms_min  smallint,
clsrms_min_ppu  smallint,
clsrms_min_kun  smallint,
clsrms_min_tnt  smallint,
clsrms_maj  smallint,
clsrms_maj_ppu  smallint,
clsrms_maj_kuc  smallint,
clsrms_maj_tnt  smallint,
land_avl_yn  smallint,
hm_room_yn  smallint,
toilet_yn  smallint,
toiletb  smallint,
toiletb_fun  smallint,
toiletg  smallint,
toiletg_fun  smallint,
toiletb_cwsn  smallint,
toiletb_cwsn_fun  smallint,
toiletg_cwsn  smallint,
toiletg_cwsn_fun  smallint,
urinalsb  smallint,
urinalsb_fun  smallint,
urinalsg  smallint,
urinalsg_fun  smallint,
toiletb_fun_water  smallint,
toiletg_fun_water  smallint,
handwash_yn  smallint,
incinerator_yn  smallint,
drink_water_yn  smallint,
hand_pump_tot  smallint,
hand_pump_fun  smallint,
well_prot_tot  smallint,
well_prot_fun  smallint,
well_unprot_tot  smallint,
well_unprot_fun  smallint,
tap_tot  smallint,
tap_fun  smallint,
pack_water  smallint,
pack_water_fun  smallint,
othsrc_tot  smallint,
othsrc_fun  smallint,
othsrc_name  varchar(100),
water_purifier_yn  smallint,
water_tested_yn  smallint,
rain_harvest_yn  smallint,
handwash_meal_yn  smallint,
handwash_meal_tot  smallint,
electricity_yn  smallint,
solarpanel_yn  smallint,
library_yn  smallint,
lib_books  integer,
lib_books_ncert  integer,
bookbank_yn  smallint,
bkbnk_books  integer,
bkbnk_books_ncert  integer,
readcorner_yn  smallint,
readcorner_books  integer,
librarian_yn  smallint,
newspaper_yn  smallint,
playground_yn  smallint,
playground_alt_yn  smallint,
medchk_yn  smallint,
medchk_tot  smallint,
dewormtab_yn  smallint,
irontab_yn  smallint,
ramps_yn  smallint,
handrails_yn  smallint,
spl_educator_yn  smallint,
kitchen_garden_yn  smallint,
dstbn_clsrms_yn  smallint,
dstbn_toilet_yn  smallint,
dstbn_kitchen_yn  smallint,
stus_hv_furnt  smallint,
ahmvp_room_yn  smallint,
comroom_g_yn  smallint,
staff_room_yn  smallint,
craft_room_yn  smallint,
staff_qtr_yn  smallint,
integrated_lab_yn  smallint,
library_room_yn  smallint,
comp_room_yn  smallint,
tinkering_lab_yn  smallint,
phy_lab_yn  smallint,
phy_lab_cond  smallint,
chem_lab_yn  smallint,
chem_lab_cond  smallint,
boi_lab_yn  smallint,
bio_lab_cond  smallint,
math_lab_yn  smallint,
math_lab_cond  smallint,
lang_lab_yn  smallint,
lang_lab_cond  smallint,
geo_lab_yn  smallint,
geo_lab_cond  smallint,
homesc_lab_yn  smallint,
home_sc_lab_cond  smallint,
psycho_lab_yn  smallint,
psycho_lab_cond  smallint,
audio_system_yn  smallint,
sciencekit_yn  smallint,
mathkit_yn  smallint,
biometric_dev_yn  smallint,
comp_lab_type  smallint,
ict_impl_year  smallint,
ictlab_fun_yn  smallint,
ict_model_impl  smallint,
ict_instr_type  smallint,
laptop_yn  smallint,
laptop_tot  smallint,
laptop_fun  smallint,
tablets_yn  smallint,
tablets_tot  smallint,
tablets_fun  smallint,
desktop_yn  smallint,
desktop_tot  smallint,
desktop_fun  smallint,
teachdev_yn  smallint,
teachdev_tot  smallint,
teachdev_fun  smallint,
digi_board_yn  smallint,
digi_board_tot  smallint,
digi_board_fun  smallint,
server_yn  smallint,
server_tot  smallint,
server_fun  smallint,
projector_yn  smallint,
projector_tot  smallint,
projector_fun  smallint,
led_yn  smallint,
led_tot  smallint,
led_fun  smallint,
printer_yn  smallint,
printer_tot  smallint,
printer_fun  smallint,
scanner_yn  smallint,
scanner_tot  smallint,
scanner_fun  smallint,
webcam_yn  smallint,
webcam_tot  smallint,
webcam_fun  smallint,
generator_yn  smallint,
generator_tot  smallint,
generator_fun  smallint,
internet_yn  smallint,
dth_yn  smallint,
digi_res_yn  smallint,
tech_soln_yn  smallint,
ict_tools_yn  smallint,
ict_teach_hrs  smallint
);

create table if not exists udise_sch_profile(
udise_sch_code  bigint primary key not null,
ac_year  text,
address  varchar(100),
c0_sec  smallint,
c1_sec  smallint,
c2_sec  smallint,
c3_sec  smallint,
c4_sec  smallint,
c5_sec  smallint,
c6_sec  smallint,
c7_sec  smallint,
c8_sec  smallint,
c9_sec  smallint,
c10_sec  smallint,
c11_sec  smallint,
c12_sec  smallint,
estd_year   varchar(10),
recog_year_pri   varchar(10),
recog_year_upr   varchar(10),
recog_year_sec   varchar(10),
recog_year_hsec   varchar(10),
upgrd_year_ele   varchar(10),
upgrd_year_sec   varchar(10),
upgrd_year_hsec   varchar(10),
cwsn_sch_yn  smallint,
shift_sch_yn  smallint,
resi_sch_yn  smallint,
resi_sch_type  int,
boarding_pri_yn  smallint,
boarding_pri_b  smallint,
boarding_pri_g  smallint,
boarding_upr_yn  smallint,
boarding_upr_b  smallint,
boarding_upr_g  smallint,
boarding_sec_yn  smallint,
boarding_sec_b  smallint,
boarding_sec_g  smallint,
boarding_hsec_yn  smallint,
boarding_hsec_b  smallint,
boarding_hsec_g  smallint,
minority_yn  smallint,
minority_type  smallint,
mtongue_pri  smallint,
medinstr1  smallint,
medinstr2  smallint,
medinstr3  smallint,
medinstr4  smallint,
medinstr_oth  varchar(100),
lang1  smallint,
lang2  smallint,
lang3  smallint,
prevoc_yn  smallint,
eduvoc_yn  smallint,
board_sec  smallint,
board_sec_no  varchar(100),
board_sec_oth  varchar(100),
board_hsec  smallint,
board_hsec_no  varchar(100),
board_hsec_oth  varchar(100),
distance_pri  double precision,
distance_upr  double precision,
distance_sec  double precision,
distance_hsec  double precision,
approach_road_yn  smallint,
ppsec_yn  smallint,
ppstu_lkg_b  smallint,
ppstu_lkg_g  smallint,
ppstu_ukg_b  smallint,
ppstu_ukg_g  smallint,
anganwadi_yn  smallint,
anganwadi_code  varchar(100),
anganwadi_stu_b  smallint,
anganwadi_stu_g  smallint,
anganwadi_tch_trained  smallint,
workdays_pre_pri  smallint,
workdays_pri  smallint,
workdays_upr  smallint,
workdays_sec  smallint,
workdays_hsec  smallint,
sch_hrs_stu_pre_pri  double precision,
sch_hrs_stu_pri  double precision,
sch_hrs_stu_upr  double precision,
sch_hrs_stu_sec  double precision,
sch_hrs_stu_hsec  double precision,
sch_hrs_tch_pre_pri  double precision,
sch_hrs_tch_pri  double precision,
sch_hrs_tch_upr  double precision,
sch_hrs_tch_sec  double precision,
sch_hrs_tch_hsec  double precision,
cce_yn_pri  smallint,
cce_yn_upr  smallint,
cce_yn_sec  smallint,
cce_yn_hsec  smallint,
pcr_maintained_yn  smallint,
pcr_shared_yn  smallint,
rte_25p_applied  smallint,
rte_25p_enrolled  smallint,
rte_pvt_c0_b  smallint,
rte_pvt_c0_g  smallint,
rte_pvt_c1_b  smallint,
rte_pvt_c1_g  smallint,
rte_pvt_c2_b  smallint,
rte_pvt_c2_g  smallint,
rte_pvt_c3_b  smallint,
rte_pvt_c3_g  smallint,
rte_pvt_c4_b  smallint,
rte_pvt_c4_g  smallint,
rte_pvt_c5_b  smallint,
rte_pvt_c5_g  smallint,
rte_pvt_c6_b  smallint,
rte_pvt_c6_g  smallint,
rte_pvt_c7_b  smallint,
rte_pvt_c7_g  smallint,
rte_pvt_c8_b  smallint,
rte_pvt_c8_g  smallint,
rte_bld_c0_b  smallint,
rte_bld_c0_g  smallint,
rte_bld_c1_b  smallint,
rte_bld_c1_g  smallint,
rte_bld_c2_b  smallint,
rte_bld_c2_g  smallint,
rte_bld_c3_b  smallint,
rte_bld_c3_g  smallint,
rte_bld_c4_b  smallint,
rte_bld_c4_g  smallint,
rte_bld_c5_b  smallint,
rte_bld_c5_g  smallint,
rte_bld_c6_b  smallint,
rte_bld_c6_g  smallint,
rte_bld_c7_b  smallint,
rte_bld_c7_g  smallint,
rte_bld_c8_b  smallint,
rte_bld_c8_g  smallint,
rte_ews_c9_b  smallint,
rte_ews_c9_g  smallint,
rte_ews_c10_b  smallint,
rte_ews_c10_g  smallint,
rte_ews_c11_b  smallint,
rte_ews_c11_g  smallint,
rte_ews_c12_b  smallint,
rte_ews_c12_g  smallint,
spltrg_yn  smallint,
spltrg_cy_prov_b  smallint,
spltrg_cy_prov_g  smallint,
spltrg_py_enrol_b  smallint,
spltrg_py_enrol_g  smallint,
spltrg_py_prov_b  smallint,
spltrg_py_prov_g  smallint,
spltrg_by  smallint,
spltrg_place  smallint,
spltrg_type  smallint,
remedial_tch_enrol  smallint,
session_start_mon  smallint,
txtbk_recd_yn  smallint,
txtbk_recd_mon  smallint,
supp_mat_recd_yn  smallint,
txtbk_pre_pri_yn  smallint,
txtbk_pri_yn  smallint,
txtbk_upr_yn  smallint,
txtbk_sec_yn  smallint,
txtbk_hsec_yn  smallint,
tle_pre_pri_yn  smallint,
tle_pri_yn  smallint,
tle_upr_yn  smallint,
tle_sec_yn  smallint,
tle_hsec_yn  smallint,
playmat_pre_pri_yn  smallint,
playmat_pri_yn  smallint,
playmat_upr_yn  smallint,
playmat_sec_yn  smallint,
playmat_hsec_yn  smallint,
no_inspect  smallint,
no_visit_crc  smallint,
no_visit_brc  smallint,
no_visit_dis  smallint,
smc_yn  smallint,
smc_mem_m  smallint,
smc_mem_f  smallint,
smc_par_m  smallint,
smc_par_f  smallint,
smc_par_sc  smallint,
smc_par_st  smallint,
smc_par_ews  smallint,
smc_par_min  smallint,
smc_lgb_m  smallint,
smc_lgb_f  smallint,
smc_tch_m  smallint,
smc_tch_f  smallint,
smc_trained_m  smallint,
smc_trained_f  smallint,
smc_meetings  smallint,
smc_sdp_yn  smallint,
smc_bnkac_yn  smallint,
smdc_smc_same_yn  smallint,
smdc_yn  smallint,
smdc_mem_m  smallint,
smdc_mem_f  smallint,
smdc_par_m  smallint,
smdc_par_f  smallint,
smdc_par_ews_m  smallint,
smdc_par_ews_f  smallint,
smdc_lgb_m  smallint,
smdc_lgb_f  smallint,
smdc_ebmc_m  smallint,
smdc_ebmc_f  smallint,
smdc_women_f  smallint,
smdc_scst_m  smallint,
smdc_scst_f  smallint,
smdc_deo_m  smallint,
smdc_deo_f  smallint,
smdc_audit_m  smallint,
smdc_audit_f  smallint,
smdc_subexp_m  smallint,
smdc_subexp_f  smallint,
smdc_tch_m  smallint,
smdc_tch_f  smallint,
smdc_vp_m  smallint,
smdc_vp_f  smallint,
smdc_prin_m  smallint,
smdc_prin_f  smallint,
smdc_cp_m  smallint,
smdc_cp_f  smallint,
smdc_trained_m  smallint,
smdc_trained_f  smallint,
smdc_meetings  smallint,
smdc_sdp_yn  smallint,
smdc_bnkac_yn  smallint,
smdc_sbc_yn  smallint,
smdc_acadcom_yn  smallint,
smdc_pta_yn  smallint,
smdc_pta_meeting  smallint
);

alter table udise_sch_profile drop column if exists smc_bnk_name ;
alter table udise_sch_profile drop column if exists smc_bnk_br ;
alter table udise_sch_profile drop column if exists smc_bnkac_no ;
alter table udise_sch_profile drop column if exists smc_bnkac_ifsc ;
alter table udise_sch_profile drop column if exists smc_bnkac_name ;
alter table udise_sch_profile drop column if exists smdc_bnk_name ;
alter table udise_sch_profile drop column if exists smdc_bnk_br ;
alter table udise_sch_profile drop column if exists smdc_bnkac_no ;
alter table udise_sch_profile drop column if exists smdc_bnkac_ifsc ;
alter table udise_sch_profile drop column if exists smdc_bnkac_name ;



create table if not exists udise_sch_staff_posn(
udise_sch_code  bigint primary key not null,
ac_year  text,
tch_regular  smallint,
tch_contract  smallint,
tch_part_time  smallint,
nontch_accnt  smallint,
nontch_lib_asst  smallint,
nontch_lab_asst  smallint,
nontch_udc  smallint,
nontch_ldc  smallint,
nontch_peon  smallint,
nontch_watchman  smallint,
tch_hav_adhr  smallint
);

create table if not exists udise_tch_profile(
udise_sch_code  bigint primary key not null,
tch_code  varchar(100),
name  varchar(100),
gender  smallint,
dob  date,
social_cat  smallint,
tch_type  smallint,
nature_of_appt  smallint,
doj_service  date,
qual_acad  smallint,
qual_prof  smallint,
class_taught  smallint,
appt_sub  smallint,
sub_taught1  smallint,
sub_taught2  smallint,
trn_brc  smallint,
trn_crc  smallint,
trn_diet  smallint,
trn_other  smallint,
trng_rcvd  smallint,
trng_needed  smallint,
nontch_days  smallint,
math_upto  smallint,
science_upto  smallint,
english_upto  smallint,
lang_study_upto  smallint,
soc_study_upto  smallint,
yoj_pres_sch  varchar(100),
disability_type  smallint,
trained_cwsn  smallint,
trained_comp  smallint
);

alter table udise_tch_profile drop constraint if exists udise_tch_profile_pkey;
alter table udise_tch_profile add primary key(udise_sch_code,tch_code);

alter table udise_tch_profile drop column if exists name;
alter table udise_tch_profile drop column if exists gender;
alter table udise_tch_profile drop column if exists dob;  

/*alter table udise_tch_profile drop constraint if exists udise_tch_profile_pkey;
alter table udise_tch_profile add primary key(udise_sch_code,name,dob);
alter table udise_tch_profile alter column tch_code drop not null;*/

create table if not exists udise_sch_exmmarks_c10(
udise_sch_code  bigint not null,
ac_year  text,
item_id  smallint not null,
marks_range_id  smallint not null,
gen_b  smallint,
gen_g  smallint,
obc_b  smallint,
obc_g  smallint,
sc_b  smallint,
sc_g  smallint,
st_b  smallint,
st_g  integer,
primary key(udise_sch_code,item_id,marks_range_id)
);

create table if not exists udise_sch_exmmarks_c12(
udise_sch_code  bigint not null,
ac_year  text,
item_id  smallint not null,
marks_range_id  smallint not null,
gen_b  smallint,
gen_g  smallint,
obc_b  smallint,
obc_g  smallint,
sc_b  smallint,
sc_g  smallint,
st_b  smallint,
st_g  smallint,
primary key(udise_sch_code,item_id,marks_range_id)
);

create table if not exists udise_sch_recp_exp(
udise_sch_code  bigint primary key not null,
ac_year  text,
dev_grt_r  double precision,
dev_grt_e  double precision,
maint_grt_r  double precision,
maint_grt_e  double precision,
tlm_grt_r  double precision,
tlm_grt_e  double precision,
cw_grt_r  double precision,
cw_grt_e  double precision,
anl_grt_r  double precision,
anl_grt_e  double precision,
minrep_grt_r  double precision,
minrep_grt_e  double precision,
labrep_grt_r  double precision,
labrep_grt_e  double precision,
book_grt_r  double precision,
book_grt_e  double precision,
elec_grt_r  double precision,
elec_grt_e  double precision,
oth_grt_r  double precision,
oth_grt_e  double precision,
compo_grt_r  double precision,
compo_grt_e  double precision,
lib_grt_r  double precision,
lib_grt_e  double precision,
sport_grt_r  double precision,
sport_grt_e  double precision,
media_grt_r  double precision,
media_grt_e  double precision,
smc_grt_r  double precision,
smc_grt_e  double precision,
presch_grt_r  double precision,
presch_grt_e  double precision,
ngo_asst_yn  smallint,
ngo_asst_name  varchar(100),
ngo_asst_rcvd  double precision,
psu_asst_yn  smallint,
psu_asst_name  varchar(100),
psu_asst_rcvd  double precision,
comm_asst_yn  smallint,
comm_asst_rcvd  double precision,
comm_asst_name  varchar(100),
oth_asst_yn  smallint,
oth_asst_name  varchar(100),
oth_asst_rcvd  double precision,
ict_reg_yn  smallint,
sport_reg_yn  smallint,
lib_reg_yn  smallint
);

create table if not exists udise_nsqf_basic_info(
udise_sch_code  bigint primary key not null,
ac_year  text,
nsqf_yn  smallint,
voc_course_yn  smallint,
sec1_sub  Integer,
sec1_year  varchar(10),
sec2_sub  Integer,
sec2_year  varchar(10)
);

alter table udise_nsqf_basic_info alter column sec2_year type varchar(10);

alter table udise_nsqf_basic_info alter column sec1_year type varchar(10);


create table if not exists udise_nsqf_enr_caste(
udise_sch_code  bigint not null,
ac_year  text,
sector_no  smallint not null,
item_id  smallint not null,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
c12_b  smallint,
c12_g  smallint,
primary key(udise_sch_code,sector_no,item_id)
);

create table if not exists udise_nsqf_enr_sub_sec(
udise_sch_code  bigint not null,
ac_year  text,
sub_sector_id  smallint,
sector_no  smallint not null,
c9_b  smallint,
c9_g  smallint,
c10_b  smallint,
c10_g  smallint,
c11_b  smallint,
c11_g  smallint,
c12_b  smallint,
c12_g  smallint,
primary key(udise_sch_code,sector_no)
);

alter table udise_nsqf_enr_sub_sec drop constraint if exists udise_nsqf_enr_sub_sec_pkey;
alter table udise_nsqf_enr_sub_sec add primary key(udise_sch_code,sector_no,sub_sector_id);

create table if not exists udise_nsqf_exmres_c10(
udise_sch_code  bigint not null,
ac_year  text,
sector_no  smallint not null,
marks_range_id  smallint not null,
gen_b  smallint,
gen_g  smallint,
obc_b  smallint,
obc_g  smallint,
sc_b  smallint,
sc_g  smallint,
st_b  smallint,
st_g  smallint,
primary key(udise_sch_code,sector_no,marks_range_id)
);

create table if not exists udise_nsqf_exmres_c12(
udise_sch_code  bigint not null,
ac_year  text,
sector_no  smallint not null,
marks_range_id  smallint not null,
gen_b  smallint,
gen_g  smallint,
obc_b  smallint,
obc_g  smallint,
sc_b  smallint,
sc_g  smallint,
st_b  smallint,
st_g  smallint,
primary key(udise_sch_code,sector_no,marks_range_id)
);

create table if not exists udise_nsqf_trng_prov(
udise_sch_code  bigint not null,
ac_year  text,
agency_name  varchar(200),
sector_no  smallint not null,
cert_no  varchar(200),
cert_agency  varchar(200),
primary key(udise_sch_code,sector_no)
);

create table if not exists udise_nsqf_faculty(
udise_sch_code  bigint not null,
ac_year  text,
nsqf_faculty_id bigint ,
faculty_code  varchar(100),
name  varchar(100),
gender  smallint,
dob  date,
soc_cat  smallint,
nature_of_appt  smallint,
qual_acad  smallint,
qual_prof  smallint,
industry_exp  smallint,
training_exp  smallint,
class_taught  smallint,
appt_sec  smallint,
induc_trg_rcvd  smallint,
inserv_trg_rcvd  smallint,
primary key(udise_sch_code,nsqf_faculty_id)
);

alter table udise_nsqf_faculty add column if not exists nsqf_faculty_id bigint;
alter table udise_nsqf_faculty drop constraint if exists udise_nsqf_faculty_pkey;
alter table udise_nsqf_faculty alter column faculty_code drop not null;
alter table udise_nsqf_faculty add primary key(udise_sch_code,nsqf_faculty_id);

create table if not exists udise_sch_pgi_details(
udise_sch_code  bigint primary key not null,
ac_year  text,
tch_adhr_seed  Integer,
stu_atndnc_yn  smallint,
tch_atndnc_yn  smallint,
sch_eval_yn  smallint,
improv_plan_yn  smallint,
sch_pfms_yn  smallint
);


create table if not exists udise_sch_safety(
udise_sch_code  bigint primary key not null,
ac_year  text,
sdmp_plan_yn  smallint,
struct_safaud_yn  smallint,
nonstr_safaud_yn  smallint,
cctv_cam_yn  smallint,
fire_ext_yn  smallint,
nodal_tch_yn  smallint,
safty_trng_yn  smallint,
dismgmt_taug_yn  smallint,
slfdef_grt_yn  smallint,
slfdef_trained  smallint
);

create table if not exists udise_sch_exmres_c8(
udise_sch_code  bigint primary key not null,
academic_year  varchar(10),
gen_app_b  smallint,
gen_app_g  smallint,
obc_app_b  smallint,
obc_app_g  smallint,
sc_app_b  smallint,
sc_app_g  smallint,
st_app_b  smallint,
st_app_g  smallint,
gen_pass_b  smallint,
gen_pass_g  smallint,
obc_pass_b  smallint,
obc_pass_g  smallint,
sc_pass_b  smallint,
sc_pass_g  smallint,
st_pass_b  smallint,
st_pass_g  smallint,
gen_60p_b  smallint,
gen_60p_g  smallint,
obc_60p_b  smallint,
obc_60p_g  smallint,
sc_60p_b  smallint,
sc_60p_g  smallint,
st_60p_b  smallint,
st_60p_g  smallint
);

alter table udise_sch_exmres_c8 alter column academic_year type varchar(10);

/*Udise transaction,aggregation,config */

CREATE TABLE if not exists udise_school_metrics_trans (academic_year text  NULL ,
     udise_school_id bigint  NOT NULL ,
     no_cwsn_students_rec_incentive integer  NULL ,
     no_of_students integer DEFAULT 0 NULL ,
     no_gen_students_rec_incentive integer DEFAULT 0 NULL ,
     no_cat_students_rec_incentive integer DEFAULT 0 NULL ,
     is_students_counselling boolean  NULL ,
     avg_instruct_days numeric DEFAULT 0 NULL ,
     avg_scl_hours_childrens numeric DEFAULT 0 NULL ,
     avg_work_hours_teachers numeric DEFAULT 0 NULL ,
     is_training_oosc boolean  NULL ,
     is_txtbk_pre_pri smallint DEFAULT 0 NULL ,
     is_txtbk_pri smallint DEFAULT 0 NULL ,
     is_txtbk_upr smallint DEFAULT 0 NULL ,
     is_txtbk_sec smallint DEFAULT 0 NULL ,
     is_txtbk_hsec smallint DEFAULT 0 NULL ,
     is_tle_pre_pri smallint DEFAULT 0 NULL ,
     is_tle_pri smallint DEFAULT 0 NULL ,
     is_tle_upr smallint DEFAULT 0 NULL ,
     is_tle_sec smallint DEFAULT 0 NULL ,
     is_tle_hsec smallint DEFAULT 0 NULL ,
     is_playmat_pre_pri smallint DEFAULT 0 NULL ,
     is_playmat_pri smallint DEFAULT 0 NULL ,
     is_playmat_upr smallint DEFAULT 0 NULL ,
     is_playmat_sec smallint DEFAULT 0 NULL ,
     is_playmat_hsec smallint DEFAULT 0 NULL ,
     stu_atndnc_yn boolean  NULL ,
     tch_atndnc_yn boolean  NULL ,
     nodal_tch_yn boolean  NULL ,
     language_room boolean  NULL ,
     geography_room boolean  NULL ,
     science_room boolean  NULL ,
     psychology_room boolean  NULL ,
     total_male_smc_members integer DEFAULT 0 NULL ,
     total_female_smc_members integer DEFAULT 0 NULL ,
     total_male_smc_trained integer DEFAULT 0 NULL ,
     total_female_smc_trained integer DEFAULT 0 NULL ,
     total_meetings_smc integer DEFAULT 0 NULL ,
     is_smdc_school boolean  NULL ,
     cwsn_students integer DEFAULT 0 NULL ,
     repeaters_students integer DEFAULT 0 NULL ,
     no_students_girls integer DEFAULT 0 NULL ,
     no_of_teachers integer DEFAULT 0 NULL ,
     classrooms_good_condition integer DEFAULT 0 NULL ,
     students_pre_primary_boys integer DEFAULT 0 NULL ,
     students_pre_primary_girls integer DEFAULT 0 NULL ,
     no_of_grades integer DEFAULT 0 NULL ,
     anganwadi_boys integer DEFAULT 0 NULL ,
     anganwadi_girls integer DEFAULT 0 NULL ,
     dev_grt_r numeric DEFAULT 0 NULL ,
     dev_grt_e numeric DEFAULT 0 NULL ,
     maint_grt_r numeric DEFAULT 0 NULL ,
     maint_grt_e numeric DEFAULT 0 NULL ,
     tlm_grt_r numeric DEFAULT 0 NULL ,
     tlm_grt_e numeric DEFAULT 0 NULL ,
     cw_grt_r numeric DEFAULT 0 NULL ,
     cw_grt_e numeric DEFAULT 0 NULL ,
     anl_grt_r numeric DEFAULT 0 NULL ,
     anl_grt_e numeric DEFAULT 0 NULL ,
     minrep_grt_r numeric DEFAULT 0 NULL ,
     minrep_grt_e numeric DEFAULT 0 NULL ,
     labrep_grt_r numeric DEFAULT 0 NULL ,
     labrep_grt_e numeric DEFAULT 0 NULL ,
     book_grt_r numeric DEFAULT 0 NULL ,
     book_grt_e numeric DEFAULT 0 NULL ,
     elec_grt_r numeric DEFAULT 0 NULL ,
     elec_grt_e numeric DEFAULT 0 NULL ,
     oth_grt_r numeric DEFAULT 0 NULL ,
     oth_grt_e numeric DEFAULT 0 NULL ,
     compo_grt_r numeric DEFAULT 0 NULL ,
     compo_grt_e numeric DEFAULT 0 NULL ,
     lib_grt_r numeric DEFAULT 0 NULL ,
     lib_grt_e numeric DEFAULT 0 NULL ,
     sport_grt_r numeric DEFAULT 0 NULL ,
     sport_grt_e numeric DEFAULT 0 NULL ,
     media_grt_r numeric DEFAULT 0 NULL ,
     media_grt_e numeric DEFAULT 0 NULL ,
     smc_grt_r numeric DEFAULT 0 NULL ,
     smc_grt_e numeric DEFAULT 0 NULL ,
     presch_grt_r numeric DEFAULT 0 NULL ,
     presch_grt_e numeric DEFAULT 0 NULL ,
     laptop_fun integer DEFAULT 0 NULL ,
     tablets_fun integer DEFAULT 0 NULL ,
     desktop_fun integer DEFAULT 0 NULL ,
     server_fun integer DEFAULT 0 NULL ,
     projector_fun integer DEFAULT 0 NULL ,
     led_fun integer DEFAULT 0 NULL ,
     webcam_fun integer DEFAULT 0 NULL ,
     generator_fun integer DEFAULT 0 NULL ,
     printer_fun integer DEFAULT 0 NULL ,
     scanner_fun integer DEFAULT 0 NULL ,
     medchk_yn boolean  NULL ,
     dewormtab_yn boolean  NULL ,
     irontab_yn boolean  NULL ,
     students_got_placement_class10 integer DEFAULT 0 NULL ,
     students_got_placement_class12 integer DEFAULT 0 NULL ,
     no_students_received_incentives integer DEFAULT 0 NULL ,
     cce_yn_pri smallint DEFAULT 0 NULL ,
     cce_yn_upr smallint DEFAULT 0 NULL ,
     cce_yn_sec smallint DEFAULT 0 NULL ,
     cce_yn_hsec smallint DEFAULT 0 NULL ,
     students_enrolled_rte integer DEFAULT 0 NULL ,
     sdmp_plan_yn boolean  NULL ,
     cctv_cam_yn boolean  NULL ,
     fire_ext_yn boolean  NULL ,
     slfdef_grt_yn boolean  NULL ,
     slfdef_trained integer DEFAULT 0 NULL ,
     no_students_boys integer DEFAULT 0 NULL ,
     no_of_boys_func_toilet integer DEFAULT 0 NULL ,
     no_of_girls_func_toilet integer DEFAULT 0 NULL ,
     no_boys_func_urinals integer DEFAULT 0 NULL ,
     no_girls_func_urinals integer DEFAULT 0 NULL ,
     cwsn_sch_yn boolean  NULL ,
     anganwadi_yn boolean  NULL ,
     voc_course_yn boolean  NULL ,
     nsqf_yn boolean  NULL ,
     no_visit_crc integer DEFAULT 0 NULL ,
     no_visit_brc integer DEFAULT 0 NULL ,
     no_visit_dis integer DEFAULT 0 NULL ,
     students_passed_class10 integer DEFAULT 0 NULL ,
     students_applied_class10 integer DEFAULT 0 NULL ,
     students_passed_class12 integer DEFAULT 0 NULL ,
     students_applied_class12 integer DEFAULT 0 NULL ,
     phy_lab_yn boolean  NULL ,
     chem_lab_yn boolean  NULL ,
     bio_lab_yn boolean  NULL ,
     math_lab_yn boolean  NULL ,
     tch_avg_years_service integer DEFAULT 0 NULL ,
     trn_brc integer DEFAULT 0 NULL ,
     trn_crc integer DEFAULT 0 NULL ,
     trn_diet integer DEFAULT 0 NULL ,
     trn_other integer DEFAULT 0 NULL ,
     trained_cwsn integer DEFAULT 0 NULL ,
     trained_comp integer DEFAULT 0 NULL ,
     students_applied_class8 integer  NULL ,
     students_passed_class8 integer  NULL ,
     students_scored_above60_c8 integer  NULL ,
     no_of_newadm_kids integer  NULL ,
     no_of_newadm_boy_kids integer  NULL ,
     no_of_newadm_girl_kids integer  NULL ,
     students_opt_placement_class12 integer  NULL ,
     students_opt_voc_fields_class12 integer  NULL ,
     students_opt_non_voc_fields_class12 integer  NULL ,
     no_of_students_self_employed_class12 integer  NULL ,
     total_nsqf_class_conducted integer  NULL ,
     students_applied_class5 integer  NULL ,
     students_passed_class5 integer  NULL ,
     students_scored_above60_c5 integer  NULL ,
     students_opt_placement_class10 integer  NULL ,
     students_opt_voc_fields_class10 integer  NULL ,
     students_opt_non_voc_fields_class10 integer  NULL ,
     no_of_students_self_employed_class10 integer  NULL ,
     total_blocks integer  NULL ,
     total_blocks_pucca integer  NULL ,
     total_classrooms integer  NULL ,
     total_classrooms_instructional integer  NULL ,
     land_available_expansion smallint  NULL ,
     have_toilet smallint  NULL ,
     no_of_boys_toilet integer  NULL ,
     no_of_girls_toilet integer  NULL ,
     no_of_boys_cwsn_toilet integer  NULL ,
     no_of_boys_cwsn_func_toilet integer  NULL ,
     no_of_girls_cwsn_toilet integer  NULL ,
     no_of_girls_cwsn_func_toilet integer  NULL ,
     no_of_boys_urinals integer  NULL ,
     no_of_girls_urinals integer  NULL ,
     handwash_available smallint  NULL ,
     incinerator_girls_toilet smallint  NULL ,
     drinking_water smallint  NULL ,
     no_of_hand_pumps integer  NULL ,
     no_of_func_hand_pumps integer  NULL ,
     no_of_well integer  NULL ,
     no_of_func_well integer  NULL ,
     no_of_tap_water integer  NULL ,
     no_of_func_tap_water integer  NULL ,
     no_of_bottle_water integer  NULL ,
     no_of_func_bottle_water integer  NULL ,
     water_purifier smallint  NULL ,
     electricity_available smallint  NULL ,
     solar_panel_available smallint  NULL ,
     library_available smallint  NULL ,
     no_of_library_books integer  NULL ,
     playground smallint  NULL ,
     playground_alt smallint  NULL ,
     ramps smallint  NULL ,
     hand_rail smallint  NULL ,
     no_of_students_hv_furniture integer  NULL ,
     integrated_science_lab smallint  NULL ,
     library_room smallint  NULL ,
     computer_lab smallint  NULL ,
     tinkering_lab smallint  NULL ,
     science_kit smallint  NULL ,
     maths_kit smallint  NULL ,
     laptop_available smallint  NULL ,
     no_of_laptop integer  NULL ,
     tablets_available smallint  NULL ,
     no_of_tablets integer  NULL ,
     desktop_available smallint  NULL ,
     no_of_desktops integer  NULL ,
     integrated_pc_tld smallint  NULL ,
     no_of_integrated_pc_tld integer  NULL ,
     no_of_func_integrated_pc_tld integer  NULL ,
     digital_boards_with_cms smallint  NULL ,
     no_of_digital_boards_with_cms integer  NULL ,
     no_of_func_digital_boards_with_cms integer  NULL ,
     server_available smallint  NULL ,
     no_of_servers integer  NULL ,
     projectors_available smallint  NULL ,
     no_of_projectors integer  NULL ,
     led_available smallint  NULL ,
     no_of_led integer  NULL ,
     printer_available smallint  NULL ,
     no_of_printers integer  NULL ,
     scanner_available smallint  NULL ,
     no_of_scanners integer  NULL ,
     web_cam_available smallint  NULL ,
     no_of_web_cams integer  NULL ,
     generator_available smallint  NULL ,
     no_of_generators integer  NULL ,
     internet_available smallint  NULL ,
     dth_available smallint  NULL ,
     digital_resources smallint  NULL ,
     tech_based_sol_cwsn smallint  NULL ,
     ict_for_teaching smallint  NULL ,
     no_of_fresh_students_enrolled integer  NULL ,
     nontch_days integer  NULL ,
     no_of_sections_class0 integer  NULL ,
     no_of_sections_class1 integer  NULL ,
     no_of_sections_class2 integer  NULL ,
     no_of_sections_class3 integer  NULL ,
     no_of_sections_class4 integer  NULL ,
     no_of_sections_class5 integer  NULL ,
     no_of_sections_class6 integer  NULL ,
     no_of_sections_class7 integer  NULL ,
     no_of_sections_class8 integer  NULL ,
     no_of_sections_class9 integer  NULL ,
     no_of_sections_class10 integer  NULL ,
     no_of_sections_class11 integer  NULL ,
     no_of_sections_class12 integer  NULL ,
     school_established_age integer  NULL ,
     shift_sch_yn smallint  NULL ,
     resi_sch_yn smallint  NULL ,
     boarding_pri_yn smallint  NULL ,
     boarding_pri_b smallint  NULL ,
     boarding_pri_g smallint  NULL ,
     boarding_upr_yn smallint  NULL ,
     boarding_upr_b smallint  NULL ,
     boarding_upr_g smallint  NULL ,
     boarding_sec_yn smallint  NULL ,
     boarding_sec_b smallint  NULL ,
     boarding_sec_g smallint  NULL ,
     boarding_hsec_yn smallint  NULL ,
     boarding_hsec_b smallint  NULL ,
     boarding_hsec_g smallint  NULL ,
     minority_yn smallint  NULL ,
     mtongue_pri smallint  NULL ,
     prevoc_yn smallint  NULL ,
     anganwadi_tch_trained smallint  NULL ,
     no_of_hsec_boys_rte integer  NULL ,
     no_of_hsec_girls_rte integer  NULL ,
     no_of_hsec_boys_rte_facility integer  NULL ,
     no_of_hsec_girls_rte_facility integer  NULL ,
     no_of_ews_hs_boys_rte_enr integer  NULL ,
     no_of_ews_hs_girls_rte_enr integer  NULL ,
     spltrg_cy_prov_b integer  NULL ,
     spltrg_cy_prov_g integer  NULL ,
     spltrg_py_enrol_b integer  NULL ,
     spltrg_py_enrol_g integer  NULL ,
     spltrg_py_prov_b integer  NULL ,
     spltrg_py_prov_g integer  NULL ,
     remedial_tch_enrol integer  NULL ,
     no_inspect integer  NULL ,
     smc_par_m integer  NULL ,
     smc_par_f integer  NULL ,
     smc_par_sc integer  NULL ,
     smc_par_st integer  NULL ,
     smc_par_ews integer  NULL ,
     smc_par_min integer  NULL ,
     smc_lgb_m integer  NULL ,
     smc_lgb_f integer  NULL ,
     smc_tch_m integer  NULL ,
     smc_tch_f integer  NULL ,
     smdc_mem_m integer  NULL ,
     smdc_mem_f integer  NULL ,
     smdc_par_m integer  NULL ,
     smdc_par_f integer  NULL ,
     smdc_par_ews_m integer  NULL ,
     smdc_par_ews_f integer  NULL ,
     smdc_lgb_m integer  NULL ,
     smdc_lgb_f integer  NULL ,
     smdc_ebmc_m integer  NULL ,
     smdc_ebmc_f integer  NULL ,
     smdc_women_f integer  NULL ,
     smdc_scst_m integer  NULL ,
     smdc_scst_f integer  NULL ,
     smdc_deo_m integer  NULL ,
     smdc_deo_f integer  NULL ,
     smdc_audit_m integer  NULL ,
     smdc_audit_f integer  NULL ,
     smdc_subexp_m integer  NULL ,
     smdc_subexp_f integer  NULL ,
     smdc_tch_m integer  NULL ,
     smdc_tch_f integer  NULL ,
     smdc_trained_m integer  NULL ,
     smdc_trained_f integer  NULL ,
     smdc_meetings integer  NULL ,
     smdc_sdp_yn integer  NULL ,
     smdc_pta_meeting integer  NULL ,
     tch_regular integer  NULL ,
     tch_contract integer  NULL ,
     tch_part_time integer  NULL ,
     nontch_accnt integer  NULL ,
     nontch_lib_asst integer  NULL ,
     nontch_lab_asst integer  NULL ,
     nontch_udc integer  NULL ,
     nontch_ldc integer  NULL ,
     nontch_peon integer  NULL ,
     nontch_watchman integer  NULL ,
     nsqf_tch_industry_exp integer  NULL ,
     nsqf_tch_training_exp integer  NULL ,
     sch_eval_yn smallint  NULL ,
     improv_plan_yn smallint  NULL ,
     sch_pfms_yn smallint  NULL ,
     struct_safaud_yn smallint  NULL ,
     nonstr_safaud_yn smallint  NULL ,
     safty_trng_yn smallint  NULL ,
     dismgmt_taug_yn smallint  NULL ,
     ngo_asst_yn smallint  NULL ,
     psu_asst_yn smallint  NULL ,
     comm_asst_yn smallint  NULL ,
     oth_asst_yn smallint  NULL ,
     ict_reg_yn smallint  NULL ,
     sport_reg_yn smallint  NULL ,
     lib_reg_yn smallint  NULL ,
     primary key(udise_school_id),
     created_on timestamp without time zone  NULL ,
     updated_on timestamp without time zone  NULL); 

create table if not exists udise_metrics_range(
metric_id serial,
metric_name text,
range numeric[],
direction text,
created_on timestamp,
updated_on timestamp,
primary key(metric_name)
);

create table if not exists udise_config(
id integer,
description text,
column_name text,
type text,
indice_id integer,
status boolean,
score numeric,
trans_columns text,
direction text,
metric_config text default 'static',
created_on timestamp,
updated_on timestamp,
primary key(id)
);

/*udise_school_metrics_trans*/

alter table udise_school_metrics_trans add COLUMN if not exists     no_cwsn_students_rec_incentive integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_students integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_gen_students_rec_incentive integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_cat_students_rec_incentive integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_students_counselling boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     avg_instruct_days numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     avg_scl_hours_childrens numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     avg_work_hours_teachers numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_training_oosc boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_txtbk_pre_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_txtbk_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_txtbk_upr smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_txtbk_sec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_txtbk_hsec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_tle_pre_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_tle_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_tle_upr smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_tle_sec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_tle_hsec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_playmat_pre_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_playmat_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_playmat_upr smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_playmat_sec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_playmat_hsec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     stu_atndnc_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tch_atndnc_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nodal_tch_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     language_room boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     geography_room boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     science_room boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     psychology_room boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_male_smc_members integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_female_smc_members integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_male_smc_trained integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_female_smc_trained integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_meetings_smc integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     is_smdc_school boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cwsn_students integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     repeaters_students integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_students_girls integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_teachers integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     classrooms_good_condition integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_pre_primary_boys integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_pre_primary_girls integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_grades integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     anganwadi_boys integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     anganwadi_girls integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     dev_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     dev_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     maint_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     maint_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tlm_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tlm_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cw_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cw_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     anl_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     anl_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     minrep_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     minrep_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     labrep_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     labrep_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     book_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     book_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     elec_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     elec_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     oth_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     oth_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     compo_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     compo_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     lib_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     lib_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     sport_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     sport_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     media_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     media_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     presch_grt_r numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     presch_grt_e numeric DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     laptop_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tablets_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     desktop_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     server_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     projector_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     led_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     webcam_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     generator_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     printer_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     scanner_fun integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     medchk_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     dewormtab_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     irontab_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_got_placement_class10 integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_got_placement_class12 integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_students_received_incentives integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cce_yn_pri smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cce_yn_upr smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cce_yn_sec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cce_yn_hsec smallint DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_enrolled_rte integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     sdmp_plan_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cctv_cam_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     fire_ext_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     slfdef_grt_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     slfdef_trained integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_students_boys integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_boys_func_toilet integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_girls_func_toilet integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_boys_func_urinals integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_girls_func_urinals integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     cwsn_sch_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     anganwadi_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     voc_course_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nsqf_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_visit_crc integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_visit_brc integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_visit_dis integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_passed_class10 integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_applied_class10 integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_passed_class12 integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_applied_class12 integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     phy_lab_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     chem_lab_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     bio_lab_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     math_lab_yn boolean  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tch_avg_years_service integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     trn_brc integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     trn_crc integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     trn_diet integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     trn_other integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     trained_cwsn integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     trained_comp integer DEFAULT 0 NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_applied_class8 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_passed_class8 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_scored_above60_c8 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_newadm_kids integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_newadm_boy_kids integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_newadm_girl_kids integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_opt_placement_class12 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_opt_voc_fields_class12 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_opt_non_voc_fields_class12 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_students_self_employed_class12 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_nsqf_class_conducted integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_applied_class5 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_passed_class5 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_scored_above60_c5 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_opt_placement_class10 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_opt_voc_fields_class10 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     students_opt_non_voc_fields_class10 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_students_self_employed_class10 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_blocks integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_blocks_pucca integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_classrooms integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     total_classrooms_instructional integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     land_available_expansion smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     have_toilet smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_boys_toilet integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_girls_toilet integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_boys_cwsn_toilet integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_boys_cwsn_func_toilet integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_girls_cwsn_toilet integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_girls_cwsn_func_toilet integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_boys_urinals integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_girls_urinals integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     handwash_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     incinerator_girls_toilet smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     drinking_water smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_hand_pumps integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_func_hand_pumps integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_well integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_func_well integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_tap_water integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_func_tap_water integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_bottle_water integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_func_bottle_water integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     water_purifier smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     electricity_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     solar_panel_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     library_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_library_books integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     playground smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     playground_alt smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     ramps smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     hand_rail smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_students_hv_furniture integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     integrated_science_lab smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     library_room smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     computer_lab smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tinkering_lab smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     science_kit smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     maths_kit smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     laptop_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_laptop integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tablets_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_tablets integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     desktop_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_desktops integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     integrated_pc_tld smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_integrated_pc_tld integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_func_integrated_pc_tld integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     digital_boards_with_cms smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_digital_boards_with_cms integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_func_digital_boards_with_cms integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     server_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_servers integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     projectors_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_projectors integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     led_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_led integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     printer_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_printers integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     scanner_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_scanners integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     web_cam_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_web_cams integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     generator_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_generators integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     internet_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     dth_available smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     digital_resources smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tech_based_sol_cwsn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     ict_for_teaching smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_fresh_students_enrolled integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_days integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class0 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class1 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class2 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class3 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class4 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class5 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class6 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class7 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class8 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class9 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class10 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class11 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_sections_class12 integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     school_established_age integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     shift_sch_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     resi_sch_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_pri_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_pri_b smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_pri_g smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_upr_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_upr_b smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_upr_g smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_sec_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_sec_b smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_sec_g smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_hsec_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_hsec_b smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     boarding_hsec_g smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     minority_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     mtongue_pri smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     prevoc_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     anganwadi_tch_trained smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_hsec_boys_rte integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_hsec_girls_rte integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_hsec_boys_rte_facility integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_hsec_girls_rte_facility integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_ews_hs_boys_rte_enr integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_of_ews_hs_girls_rte_enr integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     spltrg_cy_prov_b integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     spltrg_cy_prov_g integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     spltrg_py_enrol_b integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     spltrg_py_enrol_g integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     spltrg_py_prov_b integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     spltrg_py_prov_g integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     remedial_tch_enrol integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     no_inspect integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_par_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_par_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_par_sc integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_par_st integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_par_ews integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_par_min integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_lgb_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_lgb_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_tch_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smc_tch_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_mem_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_mem_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_par_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_par_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_par_ews_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_par_ews_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_lgb_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_lgb_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_ebmc_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_ebmc_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_women_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_scst_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_scst_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_deo_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_deo_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_audit_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_audit_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_subexp_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_subexp_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_tch_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_tch_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_trained_m integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_trained_f integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_meetings integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_sdp_yn integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     smdc_pta_meeting integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tch_regular integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tch_contract integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     tch_part_time integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_accnt integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_lib_asst integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_lab_asst integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_udc integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_ldc integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_peon integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nontch_watchman integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nsqf_tch_industry_exp integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nsqf_tch_training_exp integer  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     sch_eval_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     improv_plan_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     sch_pfms_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     struct_safaud_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     nonstr_safaud_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     safty_trng_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     dismgmt_taug_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     ngo_asst_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     psu_asst_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     comm_asst_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     oth_asst_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     ict_reg_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     sport_reg_yn smallint  NULL ;
alter table udise_school_metrics_trans add COLUMN if not exists     lib_reg_yn smallint  NULL ;

/*alter udise_config*/
alter table udise_config add COLUMN if not exists trans_columns text;
alter table udise_config add COLUMN if not exists direction text;
alter table udise_config add COLUMN if not exists metric_config text;

/*udise null table*/

create table if not exists udise_null_col(
filename varchar(200),
ff_uuid varchar(200),
count_null_udise_sch_code int,
count_null_item_id int,
count_null_stream_id int,
count_null_sector_no int,
count_null_class_type_id int,
count_null_grade_pri_upr int,
count_null_incentive_type int,
count_null_caste_id int,
count_null_disability_type int,
count_null_medinstr_seq int,
count_null_age_id int,
count_null_item_group int,
count_null_tch_code int,
count_null_marks_range_id int,
count_null_nsqf_faculty_id int
);

/*udise duplicate check tables*/

/*udise_dup_tables*/

create table if not exists udise_nsqf_plcmnt_c12_dup( udise_sch_code bigint , ac_year text, sector_no smallint , item_id smallint, opt_plcmnt_b smallint, opt_plcmnt_g smallint, placed_b smallint, placed_g smallint, voc_hs_b smallint, voc_hs_g smallint, nonvoc_hs_b smallint, nonvoc_hs_g smallint, self_emp_b smallint, self_emp_g smallint, 
num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_nsqf_plcmnt_c12_dup drop constraint if exists udise_nsqf_plcmnt_c12_dup_key;

create table if not exists udise_nsqf_plcmnt_c10_dup( udise_sch_code bigint , ac_year text, sector_no smallint , item_id smallint, opt_plcmnt_b smallint, opt_plcmnt_g smallint, placed_b smallint, placed_g smallint, voc_hs_b smallint, voc_hs_g smallint, nonvoc_hs_b smallint, nonvoc_hs_g smallint, self_emp_b smallint, self_emp_g smallint, 
num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_nsqf_plcmnt_c10_dup drop constraint if exists udise_nsqf_plcmnt_c10_dup_key;

create table if not exists udise_nsqf_class_cond_dup( udise_sch_code bigint , ac_year text, sector_no smallint , class_type_id smallint , c9 smallint, c10 smallint, c11 smallint, c12 smallint, num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_nsqf_class_cond_dup drop constraint if exists udise_nsqf_class_cond_dup_key;

create table if not exists udise_sch_exmres_c12_dup( udise_sch_code bigint , ac_year text, item_id smallint , stream_id smallint , gen_app_b smallint, gen_app_g smallint, obc_app_b smallint, obc_app_g smallint, sc_app_b smallint, sc_app_g smallint, st_app_b smallint, st_app_g smallint, gen_pass_b smallint, gen_pass_g smallint, obc_pass_b smallint, obc_pass_g smallint, sc_pass_b smallint, sc_pass_g smallint, st_pass_b smallint, st_pass_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_exmres_c12_dup drop constraint if exists udise_sch_exmres_c12_dup_key;

create table if not exists udise_sch_exmres_c10_dup( udise_sch_code bigint , ac_year text, item_id smallint , gen_app_b smallint, gen_app_g smallint, obc_app_b smallint, obc_app_g smallint, sc_app_b smallint, sc_app_g smallint, st_app_b smallint, st_app_g smallint, gen_pass_b smallint, gen_pass_g smallint, obc_pass_b smallint, obc_pass_g smallint, sc_pass_b smallint, sc_pass_g smallint, st_pass_b smallint, st_pass_g smallint, 
num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_exmres_c10_dup drop constraint if exists udise_sch_exmres_c10_dup_key;

create table if not exists udise_sch_exmres_c5_dup( udise_sch_code bigint , ac_year text, gen_app_b smallint, gen_app_g smallint, obc_app_b smallint, obc_app_g smallint, sc_app_b smallint, sc_app_g smallint, st_app_b smallint, st_app_g smallint, gen_pass_b smallint, gen_pass_g smallint, obc_pass_b smallint, obc_pass_g smallint, sc_pass_b smallint, sc_pass_g smallint, st_pass_b smallint, st_pass_g smallint, gen_60p_b smallint, gen_60p_g smallint, obc_60p_b smallint, obc_60p_g smallint, sc_60p_b smallint, sc_60p_g smallint, st_60p_b smallint, st_60p_g smallint ,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_exmres_c5_dup drop constraint if exists udise_sch_exmres_c5_dup_key;

create table if not exists udise_sch_incen_cwsn_dup( udise_sch_code bigint , ac_year text, item_id smallint , tot_pre_pri_b smallint, tot_pre_pri_g smallint, tot_pry_b smallint, tot_pry_g smallint, tot_upr_b smallint, tot_upr_g smallint, tot_sec_b smallint, tot_sec_g smallint, tot_hsec_b smallint, tot_hsec_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_incen_cwsn_dup drop constraint if exists udise_sch_incen_cwsn_dup_key;

create table if not exists udise_sch_incentives_dup( udise_sch_code bigint , ac_year text, grade_pri_upr smallint , incentive_type smallint , gen_b smallint, gen_g smallint, sc_b smallint, sc_g smallint, st_b smallint, st_g smallint, obc_b smallint, obc_g smallint, min_muslim_b smallint, min_muslim_g smallint, min_oth_b smallint, min_oth_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_incentives_dup drop constraint if exists udise_sch_incentives_dup_key;

create table if not exists udise_sch_enr_by_stream_dup( udise_sch_code bigint , ac_year text, stream_id smallint , caste_id smallint , ec11_b smallint, ec11_g smallint, ec12_b smallint, ec12_g smallint, rc11_b smallint, rc11_g smallint, rc12_b smallint, rc12_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp) ;

alter table udise_sch_enr_by_stream_dup drop constraint if exists udise_sch_enr_by_stream_dup_key;

create table if not exists udise_sch_enr_cwsn_dup( udise_sch_code bigint , ac_year text, disability_type smallint , cpp_b smallint, cpp_g smallint, c1_b smallint, c1_g smallint, c2_b smallint, c2_g smallint, c3_b smallint, c3_g smallint, c4_b smallint, c4_g smallint, c5_b smallint, c5_g smallint, c6_b smallint, c6_g smallint, c7_b smallint, c7_g smallint, c8_b smallint, c8_g smallint, c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint, c12_b smallint, c12_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_enr_cwsn_dup drop constraint if exists udise_sch_enr_cwsn_dup_key;

create table if not exists udise_sch_enr_medinstr_dup( udise_sch_code bigint , ac_year text, medinstr_seq smallint , c1_b smallint, c1_g smallint, c2_b smallint, c2_g smallint, c3_b smallint, c3_g smallint, c4_b smallint, c4_g smallint, c5_b smallint, c5_g smallint, c6_b smallint, c6_g smallint, c7_b smallint, c7_g smallint, c8_b smallint, c8_g smallint, c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_enr_medinstr_dup drop constraint if exists udise_sch_enr_medinstr_dup_key;

create table if not exists udise_sch_enr_age_dup( udise_sch_code bigint , ac_year text, age_id smallint , c1_b smallint, c1_g smallint, c2_b smallint, c2_g smallint, c3_b smallint, c3_g smallint, c4_b smallint, c4_g smallint, c5_b smallint, c5_g smallint, c6_b smallint, c6_g smallint, c7_b smallint, c7_g smallint, c8_b smallint, c8_g smallint, c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint, c12_b smallint, c12_g smallint, primary key(udise_sch_code,age_id) );

alter table udise_sch_enr_age_dup drop constraint if exists udise_sch_enr_age_dup_key;

create table if not exists udise_sch_enr_reptr_dup( udise_sch_code bigint , ac_year text, item_group smallint , item_id smallint , c1_b smallint, c1_g smallint, c2_b smallint, c2_g smallint, c3_b smallint, c3_g smallint, c4_b smallint, c4_g smallint, c5_b smallint, c5_g smallint, c6_b smallint, c6_g smallint, c7_b smallint, c7_g smallint, c8_b smallint, c8_g smallint, c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint, c12_b smallint, c12_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_enr_reptr_dup drop constraint if exists udise_sch_enr_reptr_dup_key;

create table if not exists udise_sch_enr_fresh_dup( udise_sch_code bigint , ac_year text, item_group smallint , item_id smallint , cpp_b smallint, cpp_g smallint, c1_b smallint, c1_g smallint, c2_b smallint, c2_g smallint, c3_b smallint, c3_g smallint, c4_b smallint, c4_g smallint, c5_b smallint, c5_g smallint, c6_b smallint, c6_g smallint, c7_b smallint, c7_g smallint, c8_b smallint, c8_g smallint, c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint, c12_b smallint, c12_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_enr_fresh_dup drop constraint if exists udise_sch_enr_fresh_dup_key;

create table if not exists udise_sch_enr_newadm_dup( udise_sch_code bigint , ac_year text, age4_b smallint, age4_g smallint, age5_b smallint, age5_g smallint, age6_b smallint, age6_g smallint, age7_b smallint, age7_g smallint, age8_b smallint, age8_g smallint, same_sch_b smallint, same_sch_g smallint, oth_sch_b smallint, oth_sch_g smallint, anganwadi_b smallint, anganwadi_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_enr_newadm_dup drop constraint if exists udise_sch_enr_newadm_dup_key;

create table if not exists udise_sch_facility_dup( udise_sch_code bigint , ac_year text, bld_status smallint, bld_blk_tot smallint, bld_blk smallint, bld_blk_ppu smallint, bld_blk_kuc smallint, bld_blk_tnt smallint, bld_blk_dptd smallint, bld_blk_undcons smallint, bndrywall_type smallint, clsrms_inst smallint, clsrms_und_cons smallint, clsrms_dptd smallint, clsrms_pre_pri smallint, clsrms_pri smallint, clsrms_upr smallint, clsrms_sec smallint, clsrms_hsec smallint, othrooms smallint, clsrms_gd smallint, clsrms_gd_ppu smallint, clsrms_gd_kuc smallint, clsrms_gd_tnt smallint, clsrms_min smallint, clsrms_min_ppu smallint, clsrms_min_kun smallint, clsrms_min_tnt smallint, clsrms_maj smallint, clsrms_maj_ppu smallint, clsrms_maj_kuc smallint, clsrms_maj_tnt smallint, land_avl_yn smallint, hm_room_yn smallint, toilet_yn smallint, toiletb smallint, toiletb_fun smallint, toiletg smallint, toiletg_fun smallint, toiletb_cwsn smallint, toiletb_cwsn_fun smallint, toiletg_cwsn smallint, toiletg_cwsn_fun smallint, urinalsb smallint, urinalsb_fun smallint, urinalsg smallint, urinalsg_fun smallint, toiletb_fun_water smallint, toiletg_fun_water smallint, handwash_yn smallint, incinerator_yn smallint, drink_water_yn smallint, hand_pump_tot smallint, hand_pump_fun smallint, well_prot_tot smallint, well_prot_fun smallint, well_unprot_tot smallint, well_unprot_fun smallint, tap_tot smallint, tap_fun smallint, pack_water smallint, pack_water_fun smallint, othsrc_tot smallint, othsrc_fun smallint, othsrc_name varchar(100), water_purifier_yn smallint, water_tested_yn smallint, rain_harvest_yn smallint, handwash_meal_yn smallint, handwash_meal_tot smallint, electricity_yn smallint, solarpanel_yn smallint, library_yn smallint, lib_books integer, lib_books_ncert integer, bookbank_yn smallint, bkbnk_books integer, bkbnk_books_ncert integer, readcorner_yn smallint, readcorner_books integer, librarian_yn smallint, newspaper_yn smallint, playground_yn smallint, playground_alt_yn smallint, medchk_yn smallint, medchk_tot smallint, dewormtab_yn smallint, irontab_yn smallint, ramps_yn smallint, handrails_yn smallint, spl_educator_yn smallint, kitchen_garden_yn smallint, dstbn_clsrms_yn smallint, dstbn_toilet_yn smallint, dstbn_kitchen_yn smallint, stus_hv_furnt smallint, ahmvp_room_yn smallint, comroom_g_yn smallint, staff_room_yn smallint, craft_room_yn smallint, staff_qtr_yn smallint, integrated_lab_yn smallint, library_room_yn smallint, comp_room_yn smallint, tinkering_lab_yn smallint, phy_lab_yn smallint, phy_lab_cond smallint, chem_lab_yn smallint, chem_lab_cond smallint, boi_lab_yn smallint, bio_lab_cond smallint, math_lab_yn smallint, math_lab_cond smallint, lang_lab_yn smallint, lang_lab_cond smallint, geo_lab_yn smallint, geo_lab_cond smallint, homesc_lab_yn smallint, home_sc_lab_cond smallint, psycho_lab_yn smallint, psycho_lab_cond smallint, audio_system_yn smallint, sciencekit_yn smallint, mathkit_yn smallint, biometric_dev_yn smallint, comp_lab_type smallint, ict_impl_year smallint, ictlab_fun_yn smallint, ict_model_impl smallint, ict_instr_type smallint, laptop_yn smallint, laptop_tot smallint, laptop_fun smallint, tablets_yn smallint, tablets_tot smallint, tablets_fun smallint, desktop_yn smallint, desktop_tot smallint, desktop_fun smallint, teachdev_yn smallint, teachdev_tot smallint, teachdev_fun smallint, digi_board_yn smallint, digi_board_tot smallint, digi_board_fun smallint, server_yn smallint, server_tot smallint, server_fun smallint, projector_yn smallint, projector_tot smallint, projector_fun smallint, led_yn smallint, led_tot smallint, led_fun smallint, printer_yn smallint, printer_tot smallint, printer_fun smallint, scanner_yn smallint, scanner_tot smallint, scanner_fun smallint, webcam_yn smallint, webcam_tot smallint, webcam_fun smallint, generator_yn smallint, generator_tot smallint, generator_fun smallint, internet_yn smallint, dth_yn smallint, digi_res_yn smallint, tech_soln_yn smallint, ict_tools_yn smallint, ict_teach_hrs smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_facility_dup drop constraint if exists udise_sch_facility_dup_key;

create table if not exists udise_sch_profile_dup( udise_sch_code bigint , 
ac_year text, c0_sec smallint, c1_sec smallint, c2_sec smallint, c3_sec smallint, c4_sec smallint, 
c5_sec smallint, c6_sec smallint, c7_sec smallint, c8_sec smallint, c9_sec smallint, c10_sec smallint, 
c11_sec smallint, c12_sec smallint, estd_year varchar(10), recog_year_pri varchar(10), recog_year_upr varchar(10), 
recog_year_sec varchar(10), recog_year_hsec varchar(10), upgrd_year_ele varchar(10), upgrd_year_sec varchar(10), 
upgrd_year_hsec varchar(10), cwsn_sch_yn smallint, shift_sch_yn smallint, resi_sch_yn smallint, resi_sch_type int, 
boarding_pri_yn smallint, boarding_pri_b smallint, boarding_pri_g smallint, boarding_upr_yn smallint, boarding_upr_b smallint, 
boarding_upr_g smallint, boarding_sec_yn smallint, boarding_sec_b smallint, boarding_sec_g smallint, boarding_hsec_yn smallint, 
boarding_hsec_b smallint, boarding_hsec_g smallint, minority_yn smallint, minority_type smallint, mtongue_pri smallint, medinstr1 smallint, 
medinstr2 smallint, medinstr3 smallint, medinstr4 smallint, medinstr_oth varchar(100), lang1 smallint, lang2 smallint, lang3 smallint, 
prevoc_yn smallint, eduvoc_yn smallint, board_sec smallint, board_sec_no varchar(100), board_sec_oth varchar(100), board_hsec smallint, 
board_hsec_no varchar(100), board_hsec_oth varchar(100), distance_pri double precision, distance_upr double precision, 
distance_sec double precision, distance_hsec double precision, approach_road_yn smallint, ppsec_yn smallint, ppstu_lkg_b smallint, 
ppstu_lkg_g smallint, ppstu_ukg_b smallint, ppstu_ukg_g smallint, anganwadi_yn smallint, anganwadi_code varchar(100), anganwadi_stu_b smallint, 
anganwadi_stu_g smallint, anganwadi_tch_trained smallint, workdays_pre_pri smallint, workdays_pri smallint, workdays_upr smallint, workdays_sec smallint, 
workdays_hsec smallint, sch_hrs_stu_pre_pri double precision, sch_hrs_stu_pri double precision, sch_hrs_stu_upr double precision, 
sch_hrs_stu_sec double precision, sch_hrs_stu_hsec double precision, sch_hrs_tch_pre_pri double precision, sch_hrs_tch_pri double precision, 
sch_hrs_tch_upr double precision, sch_hrs_tch_sec double precision, sch_hrs_tch_hsec double precision, cce_yn_pri smallint, cce_yn_upr smallint, 
cce_yn_sec smallint, cce_yn_hsec smallint, pcr_maintained_yn smallint, pcr_shared_yn smallint, rte_25p_applied smallint, rte_25p_enrolled smallint, 
rte_pvt_c0_b smallint, rte_pvt_c0_g smallint, rte_pvt_c1_b smallint, rte_pvt_c1_g smallint, rte_pvt_c2_b smallint, rte_pvt_c2_g smallint, rte_pvt_c3_b smallint, 
rte_pvt_c3_g smallint, rte_pvt_c4_b smallint, rte_pvt_c4_g smallint, rte_pvt_c5_b smallint, rte_pvt_c5_g smallint, rte_pvt_c6_b smallint, rte_pvt_c6_g smallint, 
rte_pvt_c7_b smallint, rte_pvt_c7_g smallint, rte_pvt_c8_b smallint, rte_pvt_c8_g smallint, rte_bld_c0_b smallint, rte_bld_c0_g smallint, rte_bld_c1_b smallint, 
rte_bld_c1_g smallint, rte_bld_c2_b smallint, rte_bld_c2_g smallint, rte_bld_c3_b smallint, rte_bld_c3_g smallint, rte_bld_c4_b smallint, rte_bld_c4_g smallint, 
rte_bld_c5_b smallint, rte_bld_c5_g smallint, rte_bld_c6_b smallint, rte_bld_c6_g smallint, rte_bld_c7_b smallint, rte_bld_c7_g smallint, rte_bld_c8_b smallint, 
rte_bld_c8_g smallint, rte_ews_c9_b smallint, rte_ews_c9_g smallint, rte_ews_c10_b smallint, rte_ews_c10_g smallint, rte_ews_c11_b smallint, rte_ews_c11_g smallint, 
rte_ews_c12_b smallint, rte_ews_c12_g smallint, spltrg_yn smallint, spltrg_cy_prov_b smallint, spltrg_cy_prov_g smallint, spltrg_py_enrol_b smallint, 
spltrg_py_enrol_g smallint, spltrg_py_prov_b smallint, spltrg_py_prov_g smallint, spltrg_by smallint, spltrg_place smallint, spltrg_type smallint, 
remedial_tch_enrol smallint, session_start_mon smallint, txtbk_recd_yn smallint, txtbk_recd_mon smallint, supp_mat_recd_yn smallint, txtbk_pre_pri_yn smallint, 
txtbk_pri_yn smallint, txtbk_upr_yn smallint, txtbk_sec_yn smallint, txtbk_hsec_yn smallint, tle_pre_pri_yn smallint, tle_pri_yn smallint, tle_upr_yn smallint, 
tle_sec_yn smallint, tle_hsec_yn smallint, playmat_pre_pri_yn smallint, playmat_pri_yn smallint, playmat_upr_yn smallint, playmat_sec_yn smallint, playmat_hsec_yn smallint, 
no_inspect smallint, no_visit_crc smallint, no_visit_brc smallint, no_visit_dis smallint, smc_yn smallint, smc_mem_m smallint, smc_mem_f smallint, 
smc_par_m smallint, smc_par_f smallint, smc_par_sc smallint, smc_par_st smallint, smc_par_ews smallint, smc_par_min smallint, smc_lgb_m smallint, 
smc_lgb_f smallint, smc_tch_m smallint, smc_tch_f smallint, smc_trained_m smallint, smc_trained_f smallint, smc_meetings smallint, smc_sdp_yn smallint, 
smc_bnkac_yn smallint, smdc_smc_same_yn smallint, smdc_yn smallint, smdc_mem_m smallint, smdc_mem_f smallint, smdc_par_m smallint, smdc_par_f smallint, 
smdc_par_ews_m smallint, smdc_par_ews_f smallint, smdc_lgb_m smallint, smdc_lgb_f smallint, smdc_ebmc_m smallint, smdc_ebmc_f smallint, smdc_women_f smallint, 
smdc_scst_m smallint, smdc_scst_f smallint, smdc_deo_m smallint, smdc_deo_f smallint, smdc_audit_m smallint, smdc_audit_f smallint, smdc_subexp_m smallint, 
smdc_subexp_f smallint, smdc_tch_m smallint, smdc_tch_f smallint, smdc_vp_m smallint, smdc_vp_f smallint, smdc_prin_m smallint, smdc_prin_f smallint, smdc_cp_m smallint, 
smdc_cp_f smallint, smdc_trained_m smallint, smdc_trained_f smallint, smdc_meetings smallint, smdc_sdp_yn smallint, smdc_bnkac_yn smallint, smdc_sbc_yn smallint, 
smdc_acadcom_yn smallint, smdc_pta_yn smallint, smdc_pta_meeting smallint ,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_profile_dup drop constraint if exists udise_sch_profile_dup_key;

alter table udise_sch_profile_dup drop column if exists smc_bnk_name ;
alter table udise_sch_profile_dup drop column if exists smc_bnk_br ;
alter table udise_sch_profile_dup drop column if exists smc_bnkac_no ;
alter table udise_sch_profile_dup drop column if exists smc_bnkac_ifsc ;
alter table udise_sch_profile_dup drop column if exists smc_bnkac_name ;
alter table udise_sch_profile_dup drop column if exists smdc_bnk_name ;
alter table udise_sch_profile_dup drop column if exists smdc_bnk_br ;
alter table udise_sch_profile_dup drop column if exists smdc_bnkac_no ;
alter table udise_sch_profile_dup drop column if exists smdc_bnkac_ifsc ;
alter table udise_sch_profile_dup drop column if exists smdc_bnkac_name ;

create table if not exists udise_sch_staff_posn_dup( udise_sch_code bigint , ac_year text, tch_regular smallint, tch_contract smallint, tch_part_time smallint, nontch_accnt smallint, nontch_lib_asst smallint, nontch_lab_asst smallint, nontch_udc smallint, nontch_ldc smallint, nontch_peon smallint, nontch_watchman smallint, tch_hav_adhr smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_staff_posn_dup drop constraint if exists udise_sch_staff_posn_dup_key;

create table if not exists udise_tch_profile_dup( udise_sch_code bigint , tch_code varchar(100), name varchar(100), gender smallint, dob date, social_cat smallint, tch_type smallint, nature_of_appt smallint, doj_service date, qual_acad smallint, qual_prof smallint, class_taught smallint, appt_sub smallint, sub_taught1 smallint, sub_taught2 smallint, trn_brc smallint, trn_crc smallint, trn_diet smallint, trn_other smallint, trng_rcvd smallint, trng_needed smallint, nontch_days smallint, math_upto smallint, science_upto smallint, english_upto smallint, lang_study_upto smallint, soc_study_upto smallint, yoj_pres_sch varchar(100), disability_type smallint, trained_cwsn smallint, trained_comp smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_tch_profile_dup drop constraint if exists udise_tch_profile_dup_key;

create table if not exists udise_sch_exmmarks_c10_dup( udise_sch_code bigint , ac_year text, item_id smallint , marks_range_id smallint , gen_b smallint, gen_g smallint, obc_b smallint, obc_g smallint, sc_b smallint, sc_g smallint, st_b smallint, st_g integer,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_exmmarks_c10_dup drop constraint if exists udise_sch_exmmarks_c10_dup_key;

create table if not exists udise_sch_exmmarks_c12_dup( udise_sch_code bigint , ac_year text, item_id smallint , marks_range_id smallint , gen_b smallint, gen_g smallint, obc_b smallint, obc_g smallint, sc_b smallint, sc_g smallint, st_b smallint, st_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_exmmarks_c12_dup drop constraint if exists udise_sch_exmmarks_c12_dup_key;

create table if not exists udise_sch_recp_exp_dup( udise_sch_code bigint , ac_year text, dev_grt_r double precision, dev_grt_e double precision, maint_grt_r double precision, maint_grt_e double precision, tlm_grt_r double precision, tlm_grt_e double precision, cw_grt_r double precision, cw_grt_e double precision, anl_grt_r double precision, anl_grt_e double precision, minrep_grt_r double precision, minrep_grt_e double precision, labrep_grt_r double precision, labrep_grt_e double precision, book_grt_r double precision, book_grt_e double precision, elec_grt_r double precision, elec_grt_e double precision, oth_grt_r double precision, oth_grt_e double precision, compo_grt_r double precision, compo_grt_e double precision, lib_grt_r double precision, lib_grt_e double precision, sport_grt_r double precision, sport_grt_e double precision, media_grt_r double precision, media_grt_e double precision, smc_grt_r double precision, smc_grt_e double precision, presch_grt_r double precision, presch_grt_e double precision, ngo_asst_yn smallint, ngo_asst_name varchar(100), ngo_asst_rcvd double precision, psu_asst_yn smallint, psu_asst_name varchar(100), psu_asst_rcvd double precision, comm_asst_yn smallint, comm_asst_rcvd double precision, comm_asst_name varchar(100), oth_asst_yn smallint, oth_asst_name varchar(100), oth_asst_rcvd double precision, ict_reg_yn smallint, sport_reg_yn smallint, lib_reg_yn smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_recp_exp_dup drop constraint if exists udise_sch_recp_exp_dup_key;

create table if not exists udise_nsqf_basic_info_dup( udise_sch_code bigint , ac_year text, nsqf_yn smallint, voc_course_yn smallint, sec1_sub Integer, sec1_year varchar(10), sec2_sub Integer, sec2_year varchar(10),num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_nsqf_basic_info_dup drop constraint if exists udise_nsqf_basic_info_dup_key;

create table if not exists udise_nsqf_enr_caste_dup( udise_sch_code bigint , ac_year text, sector_no smallint , item_id smallint , c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint, c12_b smallint, c12_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_nsqf_enr_caste_dup drop constraint if exists udise_nsqf_enr_caste_dup_key;

create table if not exists udise_nsqf_enr_sub_sec_dup( udise_sch_code bigint , ac_year text, sub_sector_id smallint, sector_no smallint , c9_b smallint, c9_g smallint, c10_b smallint, c10_g smallint, c11_b smallint, c11_g smallint, c12_b smallint, c12_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_nsqf_enr_sub_sec_dup drop constraint if exists udise_nsqf_enr_sub_sec_dup_key;

create table if not exists udise_nsqf_exmres_c10_dup( udise_sch_code bigint , ac_year text, sector_no smallint , marks_range_id smallint , gen_b smallint, gen_g smallint, obc_b smallint, obc_g smallint, sc_b smallint, sc_g smallint, st_b smallint, st_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_nsqf_exmres_c10_dup drop constraint if exists udise_nsqf_exmres_c10_dup_key;

create table if not exists udise_nsqf_exmres_c12_dup( udise_sch_code bigint , ac_year text, sector_no smallint , marks_range_id smallint , gen_b smallint, gen_g smallint, obc_b smallint, obc_g smallint, sc_b smallint, sc_g smallint, st_b smallint, st_g smallint, num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_nsqf_exmres_c12_dup drop constraint if exists udise_nsqf_exmres_c12_dup_key;

create table if not exists udise_nsqf_trng_prov_dup( udise_sch_code bigint , ac_year text, agency_name varchar(200), sector_no smallint , cert_no varchar(200), cert_agency varchar(200),num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_nsqf_trng_prov_dup drop constraint if exists udise_nsqf_trng_prov_dup_key;

create table if not exists udise_nsqf_faculty_dup( udise_sch_code bigint , ac_year text, faculty_code varchar(100) , name varchar(100), gender smallint, dob date, soc_cat smallint, nature_of_appt smallint, qual_acad smallint, qual_prof smallint, industry_exp smallint, training_exp smallint, class_taught smallint, appt_sec smallint, induc_trg_rcvd smallint, inserv_trg_rcvd smallint, num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_nsqf_faculty_dup drop constraint if exists udise_nsqf_faculty_dup_key;

create table if not exists udise_sch_pgi_details_dup( udise_sch_code bigint , ac_year text, tch_adhr_seed Integer, stu_atndnc_yn smallint, tch_atndnc_yn smallint, sch_eval_yn smallint, improv_plan_yn smallint, sch_pfms_yn smallint, num_of_times int,
ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp);

alter table udise_sch_pgi_details_dup drop constraint if exists udise_sch_pgi_details_dup_key;

create table if not exists udise_sch_safety_dup( udise_sch_code bigint , ac_year text, sdmp_plan_yn smallint, struct_safaud_yn smallint, nonstr_safaud_yn smallint, cctv_cam_yn smallint, fire_ext_yn smallint, nodal_tch_yn smallint, safty_trng_yn smallint, dismgmt_taug_yn smallint, slfdef_grt_yn smallint, slfdef_trained smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_safety_dup drop constraint if exists udise_sch_safety_dup_key;

create table if not exists udise_sch_exmres_c8_dup( udise_sch_code bigint primary key , academic_year varchar(10), gen_app_b smallint, gen_app_g smallint, obc_app_b smallint, obc_app_g smallint, sc_app_b smallint, sc_app_g smallint, st_app_b smallint, st_app_g smallint, gen_pass_b smallint, gen_pass_g smallint, obc_pass_b smallint, obc_pass_g smallint, sc_pass_b smallint, sc_pass_g smallint, st_pass_b smallint, st_pass_g smallint, gen_60p_b smallint, gen_60p_g smallint, obc_60p_b smallint, obc_60p_g smallint, sc_60p_b smallint, sc_60p_g smallint, st_60p_b smallint, st_60p_g smallint,num_of_times int,ff_uuid varchar(255),created_on_file_process timestamp default current_timestamp );

alter table udise_sch_exmres_c8_dup drop constraint if exists udise_sch_exmres_c8_dup_key;

alter table udise_null_col add column if not exists count_of_null_rows int;
