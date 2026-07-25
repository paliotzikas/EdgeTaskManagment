# A Proactive, Intelligent Mechanism for Tasks Management at the Edge

Υλοποίηση της πτυχιακής εργασίας «Ένας Προδραστικός, Ευφυής Μηχανισμός για τη
Διαχείριση Εργασιών στις Παρυφές του Δικτύου».

Το repository περιλαμβάνει ένα application-level σενάριο προσομοίωσης για
διαχείριση ουρών εργασιών σε edge κόμβους. Η εφαρμογή βασίζεται στο
[EdgeCloudSim](https://github.com/CagataySonmez/EdgeCloudSim), ένα framework
προσομοίωσης edge computing που επεκτείνει το CloudSim. Το EdgeCloudSim
χρησιμοποιείται ως το περιβάλλον εκτέλεσης και ο κώδικας της παρούσας εργασίας
υλοποιεί πάνω του τον μηχανισμό AHP–Rough Sets, χωρίς να τροποποιεί τον πυρήνα
του framework.

Για την επιστημονική περιγραφή του EdgeCloudSim, παραπέμπουμε στο πρωτότυπο
[repository του EdgeCloudSim](https://github.com/CagataySonmez/EdgeCloudSim) και
στη δημοσίευση των Sonmez, Ozgovde και Ersoy:
[EdgeCloudSim: An environment for performance evaluation of Edge Computing
systems](https://onlinelibrary.wiley.com/doi/abs/10.1002/ett.3493).

## Περιγραφή υλοποίησης

Η προσομοίωση αποτελείται από πολλούς edge κόμβους. Κάθε κόμβος διαθέτει μία
τρέχουσα εργασία και FIFO ουρά αναμονής. Οι αφίξεις παράγονται με Poisson
διαδικασία, ενώ κάθε εργασία περιγράφεται από:

- προτεραιότητα,
- πλήθος βημάτων,
- υπολογιστική πολυπλοκότητα,
- χρονικό περιθώριο μέχρι την προθεσμία,
- βασικό χρόνο εκτέλεσης.

Ο μηχανισμός απόφασης συνδυάζει:

1. **AHP** για τον υπολογισμό βαρών και τη βαθμολόγηση των εργασιών.
2. **Rough-set-inspired διαχωρισμό** σε lower, boundary και upper region.
3. **Προδραστική ενεργοποίηση** με βάση EWMA του ρυθμού αφίξεων, την πρόβλεψη
   μεγέθους ουράς και τον κίνδυνο παραβίασης προθεσμίας.
4. **Offloading** προς κόμβο με μικρότερη ουρά ή μικρότερο εκτιμώμενο χρόνο
   καθυστέρησης.
5. **Αντιδραστική εφεδρεία**, όταν η προδραστική συνθήκη δεν ενεργοποιείται.

Για συγκρίσεις υποστηρίζονται επίσης οι πολιτικές `NONE`, `FIFO` και `RANDOM`.

## Δομή repository

```text
src/edu/boun/edgecloudsim/applications/ahp_rough/
├── MainApp.java
├── ScenarioConfig.java
├── AhpRoughSimulation.java
├── AhpRoughSetSelector.java
├── EdgeNodeQueue.java
└── TaskVector.java

scripts/ahp_rough/
├── config/                         # αρχεία .properties
├── compile.ps1 / compile.sh        # μεταγλώττιση
├── run_once.ps1                    # μία εκτέλεση
├── run_scenarios.sh                # batch εκτελέσεις
├── run_proactive_comparison.ps1    # reactive/proactive σύγκριση
├── analyze_run.py                  # συγκεντρωτική ανάλυση
└── matlab/                         # γραφήματα και συγκρίσεις

```

## Προαπαιτούμενα

- Java JDK 21 ή νεότερο (`java` και `javac` στο `PATH`).
- Οι βιβλιοθήκες που περιέχονται στο `lib/`:
  `cloudsim-7.0.0-alpha.jar`, `commons-math3-3.6.1.jar` και `colt.jar`.
- Python 3 για το `analyze_run.py`.
- MATLAB, προαιρετικά, για τα plots.
- Σε Windows: PowerShell για μεμονωμένες εκτελέσεις και Git Bash/WSL για τα
  bash scripts.

## Εκτέλεση

Οι εντολές εκτελούνται από το root του repository.

### PowerShell

```powershell
.\scripts\ahp_rough\compile.ps1
.\scripts\ahp_rough\run_once.ps1 `
    -ScenarioName default_config `
    -IterationNumber 1
```

Για σύγκριση αντιδραστικής και προδραστικής λειτουργίας:

```powershell
.\scripts\ahp_rough\run_proactive_comparison.ps1 -Iterations 50
```

### Git Bash ή WSL

```bash
cd scripts/ahp_rough
./compile.sh
./run_scenarios.sh 4 50 simulation_proactive.list
```

## Ανάλυση αποτελεσμάτων

Μία εκτέλεση παράγει, ανά σενάριο και επανάληψη:

- `task_events.csv`: αφίξεις, εκκινήσεις, ολοκληρώσεις και offloading.
- `node_state.csv`: μέγεθος ουράς, ρυθμός αφίξεων και δείκτες ενεργοποίησης.
- `summary.txt`: συνοπτικούς μετρητές της εκτέλεσης.

Για συγκεντρωτική ανάλυση:

```bash
python analyze_run.py output/<simulation_id>
```

Το script δημιουργεί αναφορές και πίνακες στον φάκελο `comparison/`. Τα MATLAB
scripts στο `scripts/ahp_rough/matlab/` δημιουργούν γραφήματα για ρυθμό αφίξεων,
μέγεθος ουράς, συμβάντα εργασιών, βαθμολογίες offloading, καθυστέρηση εκτέλεσης
και συγκρίσεις σεναρίων. Οι αναλυτικές οδηγίες βρίσκονται στο
[`scripts/ahp_rough/matlab/README.md`](scripts/ahp_rough/matlab/README.md).

## Σενάρια και αναπαραγωγιμότητα

Τα αρχεία `simulation*.list` και τα `.properties` στον φάκελο
`scripts/ahp_rough/config/` καθορίζουν τα πειραματικά σενάρια. Η παράμετρος
`random_seed` εξασφαλίζει επαναληψιμότητα, ενώ το
`vary_seed_by_iteration=1` παράγει διαφορετικό, αλλά ντετερμινιστικό, seed για
κάθε επανάληψη. Για δίκαιη σύγκριση πολιτικών πρέπει να χρησιμοποιούνται οι
ίδιες παράμετροι workload και η ίδια διαδικασία seeds.

## Περιορισμοί

Το application αξιολογεί την πολιτική διαχείρισης ουρών σε ελεγχόμενο σενάριο.
Δεν αποτελεί πλήρη μοντελοποίηση πραγματικού δικτύου: η έκδοση αυτή δεν
αναπαριστά αναλυτικά bandwidth, κινητικότητα ή καθυστέρηση WLAN/WAN. Επίσης, ο
διαχωρισμός lower/boundary/upper είναι rough-set-inspired και όχι πλήρες σύστημα
εξαγωγής κανόνων Rough Sets. Οι παραδοχές αυτές πρέπει να λαμβάνονται υπόψη
κατά την ερμηνεία των πειραματικών αποτελεσμάτων.

## Πρόσθετη τεκμηρίωση

- [Τεκμηρίωση της εφαρμογής](src/edu/boun/edgecloudsim/applications/ahp_rough/README.md)

## Άδεια και προέλευση

Ο πυρήνας προσομοίωσης προέρχεται από το EdgeCloudSim. Για τους όρους χρήσης
και την άδεια του framework, ανατρέξτε στο
[repository](https://github.com/CagataySonmez/EdgeCloudSim). Οι κλάσεις
και τα scripts του φακέλου `ahp_rough` αποτελούν την υλοποίηση της παρούσας
εργασίας.
