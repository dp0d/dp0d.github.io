# 预训练模型的对比


# BERT

BERT（Bidirectional Encoder Representations from Transformers）由谷歌在2018年提出[1]。在语言模型中，它的优势是采用了动态的词向量，用以解决一词多义等问题，并且在训练阶段使用多任务——MLM（Masked Language Modeling）和NSP（Next Sentence Prediction）来融入语言学知识，前者使用了双向语义信息来编码词汇，而后者有利于下游句级关系的推理；它的缺点是掩码机制的被掩词的条件独立假设，掩码使用的特殊标记与下游微调时的不一致性以及切词时可能会破坏原词等[2]。

[1] Devlin J, Chang M W, Lee K, et al. Bert: Pre-training of deep bidirectional transformers for language understanding[J]. arXiv preprint arXiv:1810.04805, 2018.

[2] Yang Z, Dai Z, Yang Y, et al. Xlnet: Generalized autoregressive pretraining for language understanding[J]. Advances in neural information processing systems, 2019, 32.

# GPT

GPT（Generative Pre-Training）由OpenAI在2018年提出[3]。GPT模型同样采用了预训练加微调的训练策略，能够实现动态词向量，且由于其是自回归模型，相比于BERT，GPT模型可以更好地应用于自然语言生成任务。然而，GPT模型仅利用了上文信息，相比于BERT，其只能捕捉单向的语义信息。在GPT的版本更新迭代中，其参数规模迅速增长，这也导致了其难以反向传播来更新权重。

[3] Radford A, Narasimhan K, Salimans T, et al. Improving laAnguage understanding by generative pre-training[J]. 2018.

