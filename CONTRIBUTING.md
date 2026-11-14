# Guide de Contribution

Merci pour l'interet porte au projet **Au Valaisan**. Ce document definit les lignes directrices pour maintenir la qualite du code, la rigueur de la modelisation relationnelle et l'integrite du depot.

---

## 1. Principes Generaux

- **Rigueur Academique et Industrielle** : Toute modification apportee au schema relationnel doit respecter les Formes Normales (3NF / BCNF) et etre validee vis-a-vis des contraintes d'integrite.
- **Gestion Pessimiste de Concurrence** : Les transactions critiques sur les stocks doivent imperativement respecter le verrouillage pessimiste (`SELECT ... FOR UPDATE`) et l'ordre de tri FIFO sur les dates de reception de lots.
- **Sobriete et Professionnalisme** : Les messages de commit, la documentation et les commentaires de code doivent adopter un ton rigoureux, clair et depourvu d'emojis superflus.

---

## 2. Processus de Contribution

1. **Creer une branche descriptive** :
   ```bash
   git checkout -b feature/nom-de-la-fonctionnalite
   # ou
   git checkout -b fix/nom-du-correctif
   ```

2. **Format des messages de commit (Conventional Commits)** :
   Utiliser des prefixes standards sans emojis :
   - `feat:` nouvelle fonctionnalite applicative ou script SQL
   - `fix:` correction de bug ou d'anomalie transactionnelle
   - `docs:` mise a jour de la documentation ou des diagrammes
   - `refactor:` reorganisation de code sans modification fonctionnelle
   - `test:` ajout ou mise a jour de scripts de test SQL / Java
   - `chore:` maintenance de build, Makefile ou configuration CI

   Exemple :
   ```
   feat(stock): implement pessimistic FIFO locking in waste declaration
   fix(schema): add check constraint for seasonal date validity
   docs(transactions): detail isolation levels and serializability
   ```

3. **Validation Locale** :
   Avant de soumettre une pull request, verifier imperativement :
   ```bash
   make clean
   make compile
   mvn compile
   ```

4. **Soumission de la Pull Request** :
   - Fournir une description claire du probleme resolu ou de l'evolution.
   - Mentionner les tables SQL affectees et les tests realises.

---

## 3. Normes de Code

### Java (JDBC)
- Fermeture systematique des ressources JDBC (`Connection`, `PreparedStatement`, `ResultSet`) dans des blocs `try-with-resources` ou via `closeQuietly()`.
- Gestion explicite des transactions (`conn.setAutoCommit(false)`, `conn.commit()`, `conn.rollback()` dans le bloc `catch`).
- Aucune requete SQL concatenee avec des entrees utilisateur : utiliser systematiquement des `PreparedStatement` pour prevenir les injections SQL.
- Indentation standard de 4 espaces, encodage UTF-8.

### SQL (Oracle PL/SQL)
- Mots-cles SQL en majuscules (`SELECT`, `INSERT`, `UPDATE`, `COMMIT`, etc.).
- Noms de tables en PascalCase ou Snake_Case conformes au schema officiel (`Lot_Produit`, `Commande`, `Ligne_Commande`).
- Commentaires explicatifs pour chaque transaction et niveau d'isolation requis.
