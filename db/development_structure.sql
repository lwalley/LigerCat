CREATE TABLE `blast_mesh_frequencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blast_query_id` int(11) DEFAULT NULL,
  `mesh_keyword_id` int(11) DEFAULT NULL,
  `frequency` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `e_value` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_blast_mesh_frequencies_on_blast_query_id` (`blast_query_id`),
  KEY `index_blast_mesh_frequencies_on_mesh_keyword_id` (`mesh_keyword_id`),
  KEY `by_blast_query_id_and_mesh_keyword_id` (`blast_query_id`,`mesh_keyword_id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8;

CREATE TABLE `blast_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `done` tinyint(1) DEFAULT '0',
  `query_key` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_blast_queries_on_query_key` (`query_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `blast_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sequence_id` int(11) DEFAULT NULL,
  `blast_query_id` int(11) DEFAULT NULL,
  `e_value` double DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_blast_results_on_sequence_id` (`sequence_id`),
  KEY `index_blast_results_on_blast_query_id` (`blast_query_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `expanded_journal_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2172 DEFAULT CHARSET=utf8;

CREATE TABLE `gi_numbers_pmids` (
  `gi_number` int(11) NOT NULL DEFAULT '0',
  `pmid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`gi_number`,`pmid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `journal_classifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `journal_id` int(11) DEFAULT NULL,
  `journal_keyword_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_journal_classifications_on_journal_id` (`journal_id`),
  KEY `index_journal_classifications_on_journal_keyword_id` (`journal_keyword_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13391 DEFAULT CHARSET=utf8;

CREATE TABLE `journal_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8;

CREATE TABLE `journal_mesh_frequencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `journal_id` int(11) DEFAULT NULL,
  `mesh_id` int(11) DEFAULT NULL,
  `frequency` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_journal_mesh_frequencies_on_journal_id` (`journal_id`),
  KEY `index_journal_mesh_frequencies_on_mesh_id` (`mesh_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1013368 DEFAULT CHARSET=utf8;

CREATE TABLE `journal_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `max_mesh_score` int(11) DEFAULT NULL,
  `max_text_score` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `done` tinyint(1) DEFAULT '0',
  `query` text,
  `query_key` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_journal_queries_on_query_key` (`query_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `journal_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `journal_id` int(11) DEFAULT NULL,
  `journal_query_id` int(11) DEFAULT NULL,
  `search_term_score` float DEFAULT NULL,
  `mesh_score` int(11) DEFAULT NULL,
  `text_score` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_journal_results_on_journal_id` (`journal_id`),
  KEY `index_journal_results_on_journal_query_id` (`journal_query_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `journal_text_frequencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `journal_id` int(11) DEFAULT NULL,
  `text_keyword_id` int(11) DEFAULT NULL,
  `frequency` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_journal_text_frequencies_on_journal_id` (`journal_id`),
  KEY `index_journal_text_frequencies_on_text_keyword_id` (`text_keyword_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1077892 DEFAULT CHARSET=utf8;

CREATE TABLE `journals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` text,
  `nlm_id` varchar(255) DEFAULT NULL,
  `title_abbreviation` varchar(255) DEFAULT NULL,
  `issn` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `new_journal` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101484308 DEFAULT CHARSET=utf8;

CREATE TABLE `mesh_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `score` float DEFAULT NULL,
  `genbank_score` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57667 DEFAULT CHARSET=utf8;

CREATE TABLE `nuccore_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `done` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_nuccore_queries_on_query` (`query`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `nuccore_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sequence_id` int(11) DEFAULT NULL,
  `nuccore_query_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_nuccore_results_on_sequence_id` (`sequence_id`),
  KEY `index_nuccore_results_on_nuccore_query_id` (`nuccore_query_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `pmids_mesh_keywords` (
  `pmid` int(11) DEFAULT NULL,
  `mesh_keyword_id` int(11) DEFAULT NULL,
  KEY `index_pmids_mesh_ids_on_pmid_and_mesh_keyword_id` (`pmid`,`mesh_keyword_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `publication_dates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query_id` int(11) NOT NULL,
  `query_type` varchar(20) NOT NULL,
  `year` int(11) DEFAULT NULL,
  `publication_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_publication_dates_on_query_type_and_query_id` (`query_type`,`query_id`)
) ENGINE=InnoDB AUTO_INCREMENT=598 DEFAULT CHARSET=utf8;

CREATE TABLE `pubmed_mesh_frequencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pubmed_query_id` int(11) DEFAULT NULL,
  `mesh_keyword_id` int(11) DEFAULT NULL,
  `frequency` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `e_value` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pubmed_mesh_frequencies_on_pubmed_query_id` (`pubmed_query_id`),
  KEY `index_pubmed_mesh_frequencies_on_mesh_keyword_id` (`mesh_keyword_id`),
  KEY `by_pubmed_query_id_and_mesh_keyword_id` (`pubmed_query_id`,`mesh_keyword_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1028 DEFAULT CHARSET=utf8;

CREATE TABLE `pubmed_queries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `done` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `query` text,
  `query_key` varchar(40) DEFAULT NULL,
  `num_articles` int(11) DEFAULT NULL,
  `full_species_name` varchar(255) DEFAULT NULL,
  `eol_taxa_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_pubmed_queries_on_query_key` (`query_key`),
  KEY `index_pubmed_queries_on_eol_taxa_id` (`eol_taxa_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sequences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `fasta_data` text,
  `blast_query_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sequences_on_blast_query_id` (`blast_query_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `text_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `score` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38368 DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20081028193429');

INSERT INTO schema_migrations (version) VALUES ('20081028193439');

INSERT INTO schema_migrations (version) VALUES ('20081103212819');

INSERT INTO schema_migrations (version) VALUES ('20081104152949');

INSERT INTO schema_migrations (version) VALUES ('20081104153126');

INSERT INTO schema_migrations (version) VALUES ('20081114201133');

INSERT INTO schema_migrations (version) VALUES ('20081119213443');

INSERT INTO schema_migrations (version) VALUES ('20081120202055');

INSERT INTO schema_migrations (version) VALUES ('20081121210221');

INSERT INTO schema_migrations (version) VALUES ('20081212193932');

INSERT INTO schema_migrations (version) VALUES ('20081215181415');

INSERT INTO schema_migrations (version) VALUES ('20081215181532');

INSERT INTO schema_migrations (version) VALUES ('20081215181734');

INSERT INTO schema_migrations (version) VALUES ('20081215201156');

INSERT INTO schema_migrations (version) VALUES ('20081215212522');

INSERT INTO schema_migrations (version) VALUES ('20081223212622');

INSERT INTO schema_migrations (version) VALUES ('20090105220109');

INSERT INTO schema_migrations (version) VALUES ('20090218173334');

INSERT INTO schema_migrations (version) VALUES ('20090219201753');

INSERT INTO schema_migrations (version) VALUES ('20090219215406');

INSERT INTO schema_migrations (version) VALUES ('20090219231201');

INSERT INTO schema_migrations (version) VALUES ('20090219231205');

INSERT INTO schema_migrations (version) VALUES ('20090219231209');

INSERT INTO schema_migrations (version) VALUES ('20090219231213');

INSERT INTO schema_migrations (version) VALUES ('20090219231217');

INSERT INTO schema_migrations (version) VALUES ('20090219231221');

INSERT INTO schema_migrations (version) VALUES ('20090219231225');

INSERT INTO schema_migrations (version) VALUES ('20090219231229');

INSERT INTO schema_migrations (version) VALUES ('20090219231233');

INSERT INTO schema_migrations (version) VALUES ('20090219231237');

INSERT INTO schema_migrations (version) VALUES ('20090219231241');

INSERT INTO schema_migrations (version) VALUES ('20090219231245');

INSERT INTO schema_migrations (version) VALUES ('20090219231249');

INSERT INTO schema_migrations (version) VALUES ('20090219231254');

INSERT INTO schema_migrations (version) VALUES ('20090219231258');

INSERT INTO schema_migrations (version) VALUES ('20090219231302');

INSERT INTO schema_migrations (version) VALUES ('20090219231306');

INSERT INTO schema_migrations (version) VALUES ('20090219231334');

INSERT INTO schema_migrations (version) VALUES ('20090220000214');

INSERT INTO schema_migrations (version) VALUES ('20090317174919');

INSERT INTO schema_migrations (version) VALUES ('20090701165655');

INSERT INTO schema_migrations (version) VALUES ('20090722202329');

INSERT INTO schema_migrations (version) VALUES ('20091105203002');

INSERT INTO schema_migrations (version) VALUES ('20100115183154');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');