using SDL;

/*
 * Le jeu représente... le jeu :)
 */
public class Jeu
{
	/* L'écran sur lequel se déroule le jeu */
	private weak SDL.Screen ecran;
	
	/* La configuration de l'écran */
	// TODO permettre à l'utilisateur configurer ces valeurs ?
	private const int SCREEN_WIDTH = 800;
	private const int SCREEN_HEIGHT = 600;
	private const int SCREEN_BPP = 32;
	private const int DELAY = 100;
	
	/* boolean indiquant l'état du jeu */
	private bool lance;
	private bool en_pause = true;
	
	/* Permet de savoir si on maintient le clic */
	private bool bouton_est_presse = false;
	/* Le bouton de la souris sur lequel on vient de cliquer */
	private uchar bouton;
	/* Position du dernier pixel modifié à la souris */
	private int dernier_x_modifie = -1;
	private int dernier_y_modifie = -1;
	
	/* Le monde avec lequel on va jouer */
	private Monde le_monde;
	
	/*
	 * Constructeur
	 * @param taille_cellules la taille des cellules
	 * @param generation_aleatoire indique si on doit peupler le monde
	 */
	public Jeu (uint16 taille_cellules, bool generation_aleatoire) {
		initialiserVideo ();
		
		le_monde = new MondeGraphique ((int16)SCREEN_WIDTH,
		                               (int16)SCREEN_HEIGHT,
		                               taille_cellules,
		                               ecran);
		
		if (generation_aleatoire) {
			le_monde.peupler ();
		}
	}
	
	/*
	 * Lance le jeu
	 *     - Dessine le jeu
	 *     - Capture les évènements
	 *     - Avance d'une étape (si pas en pause)
	 */
	public void lancer () {
		lance = true;
		
		while (lance) {
			((MondeGraphique) le_monde).dessiner ();
			capturerEvenement ();
			
			if (!estEnPause ()) {
				le_monde.avancerEtape ();
			}
			
			SDL.Timer.delay (DELAY);
		}
	}
	
	/*
	 * Initialise l'écran
	 */
	private void initialiserVideo () {
		int flags = SurfaceFlag.DOUBLEBUF |
		            SurfaceFlag.HWACCEL |
		            SurfaceFlag.HWSURFACE;
		
		ecran = Screen.set_video_mode (SCREEN_WIDTH,
		                               SCREEN_HEIGHT,
		                               SCREEN_BPP,
		                               flags);
		if (ecran == null) {
			GLib.error ("Impossible de lancer le mode vidéo");
		}
	}
	
	/*
	 * Fonction de capture des évènements
	 */
	private void capturerEvenement () {
		Event evenement = Event ();
		
		while (Event.poll (out evenement) == 1) {
			switch (evenement.type) {
			case EventType.QUIT:
				quitter ();
				break;
			case EventType.KEYDOWN:
				evenementClavier (evenement.key);
				break;
			// TODO
			// Gérer les events suivants dans EventType.MOUSEMOTION?
			case EventType.MOUSEBUTTONDOWN:
				bouton_est_presse = true;
				bouton = evenement.button.button;
				modifierMonde (evenement.motion.x,
				               evenement.motion.y,
				               bouton);
				break;
			case EventType.MOUSEBUTTONUP:
				bouton_est_presse = false;
				dernier_x_modifie = -1;
				dernier_y_modifie = -1;
				break;
			case EventType.MOUSEMOTION:
				if (bouton_est_presse) {
					modifierMonde (evenement.motion.x,
					               evenement.motion.y,
					               bouton);
		                }
		                
				break;
			}
		}
	}
	
	/*
	 * Gère les évènements survenus au clavier
	 */
	private void evenementClavier (KeyboardEvent evenement) {
		if (evenement.keysym.sym == KeySymbol.q) {
			quitter ();
		} else if(evenement.keysym.sym == KeySymbol.SPACE) {
			basculerPause ();
		} else if(evenement.keysym.sym == KeySymbol.p) {
			((MondeGraphique) le_monde).peupler ();
		} else if(evenement.keysym.sym == KeySymbol.t) {
			le_monde.tuerLePeuple ();
		} else if(evenement.keysym.sym == KeySymbol.n) {
			le_monde.annihilerLePeuple ();
		}
	}
	
	/*
	 * Modifie une cellule en fonction du clic de souris
	 *     - si clic gauche, la cellule devient vivante
	 *     - si clic droit, on la tue
	 * @param x, y position du pixel cliqué
	 * @param bouton représente le bouton de la souris
	 */
	private void modifierMonde (uint16 x, uint16 y, uchar bouton) {
		int x_reel = x / le_monde.taille_habitants;
		int y_reel = y / le_monde.taille_habitants;
		Etat etat;
		
		if (x_reel != dernier_x_modifie
		 || y_reel != dernier_y_modifie) {
		 	if (bouton == MouseButton.LEFT) {
		 		etat = Etat.VIVANTE;
		 	} else {
		 		etat = Etat.MORTE;
		 	}
		 	
			le_monde.changerEtatCellule (x_reel, y_reel, etat);
		}
		
		dernier_x_modifie = x_reel;
		dernier_y_modifie = y_reel;
	}
	
	/*
	 * Bascule le jeu en pause
	 */
	private void basculerPause () {
		en_pause = !en_pause;
	}
	
	/*
	 * Permet de savoir si le jeu est en pause
	 * @return true si le jeu est en pause, false sinon
	 */
	private bool estEnPause () {
		return en_pause;
	}
	
	/*
	 * Permet de quitter le jeu
	 */
	private void quitter () {
		lance = false;
	}
}

/* Variables permettant de configurer le jeu */
static uint16 taille_cellules = 4;
static bool generer_aleatoirement = false;
static bool afficher_commandes = false;

/* Représente les options possibles de la ligne de commande */
const OptionEntry[] options = {
	{ "taille",    't', 0, OptionArg.INT,  ref taille_cellules,
	  "La taille des cellules",                             "<int>" },
	  
	{ "aleatoire", 'a', 0, OptionArg.NONE, ref generer_aleatoirement,
	  "Indique si le monde doit etre genere aleatoirement", null },
	  
	{ "commandes", 'c', 0, OptionArg.NONE, ref afficher_commandes,
	  "Affiche la liste des raccourcis utiles dans le jeu", null },
	  
	{ null }
};

/*
 * Configure le jeu à partir de la ligne de commandes
 * @return true si le jeu peut être lancé, false sinon
 */
public bool configurer (ref unowned string[] args) {
	var opt_context = new OptionContext ("");
	opt_context.set_help_enabled (true);
	opt_context.set_ignore_unknown_options (true);
	opt_context.add_main_entries (options, null);
	
	try {
		opt_context.parse (ref args);
	} catch (OptionError e) {
		stdout.printf ("%s\n", e.message);
		stdout.printf ("Utilisez '%s --help' pour voir la liste " +
		               "complète des options.\n", args[0]);
		return false;
	}
	
	if (afficher_commandes) {
		stdout.printf ("Commandes:\n");
		stdout.printf ("  Souris\tLe clic gauche donne la vie aux " +
		               "cellules... Le clic droit la leur reprend\n");
		stdout.printf ("  Espace\tLance le jeu ou le met en pause\n");
		stdout.printf ("  P\t\t(Re)peuple le monde\n");
		stdout.printf ("  T\t\tTue les cellules\n");
		stdout.printf ("  N\t\tTue les cellules et nettoie les " +
		               "débris cellulaires\n");
		stdout.printf ("  Q\t\tQuitte le jeu\n");
		
		return false;
	}
	
	return true;
}


/*
 * Fonction principale configurant en lançant le jeu
 */
public static void main (string[] args)
{
	SDL.init (InitFlag.VIDEO);
	SDL.WindowManager.set_caption ("Le jeu de la Vie", "");

	bool continuer = configurer (ref args);
	
	if (continuer) {
		Jeu jeu = new Jeu (taille_cellules, generer_aleatoirement);
		jeu.lancer ();
	}
	
	SDL.quit();
}
