import { BaseRepository } from './BaseRepository';
import { Doacao } from '../models/Doacao';
import { Item } from '../models/Item';
import { Voluntario } from '../models/Voluntario';
import { Beneficiario } from '../models/Beneficiario';

export class DoacaoRepository extends BaseRepository<Doacao> {
    async create(doacao: Doacao): Promise<Doacao> {
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');

            // Inserir a doação
            const doacaoResult = await client.query(
                'INSERT INTO Doacao (id_voluntario, id_beneficiario, data_doacao, tipo_doacao, status, observacoes) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
                [
                    doacao.getVoluntario().getId(),
                    doacao.getBeneficiario().getId(),
                    doacao.getDataDoacao(),
                    doacao.getTipoDoacao(),
                    doacao.getStatus(),
                    doacao.getObservacoes()
                ]
            );

            // Inserir os itens da doação
            for (const item of doacao.getItens()) {
                await client.query(
                    'INSERT INTO Item_Doacao (id_doacao, id_item, quantidade) VALUES ($1, $2, $3)',
                    [doacaoResult.rows[0].id_doacao, item.getId(), 1]
                );
            }

            await client.query('COMMIT');

            return new Doacao(
                doacaoResult.rows[0].id_doacao,
                doacao.getVoluntario(),
                doacao.getBeneficiario(),
                doacao.getItens(),
                new Date(doacaoResult.rows[0].data_doacao),
                doacaoResult.rows[0].tipo_doacao,
                doacaoResult.rows[0].status,
                doacaoResult.rows[0].observacoes
            );
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    async findById(id: number): Promise<Doacao | null> {
        const result = await this.pool.query(
            `SELECT d.*, v.*, b.*, i.*, pv.*, pb.*
             FROM Doacao d
             JOIN Voluntario v ON d.id_voluntario = v.id_voluntario
             JOIN Beneficiario b ON d.id_beneficiario = b.id_beneficiario
             JOIN Pessoa pv ON v.id_pessoa = pv.id_pessoa
             JOIN Pessoa pb ON b.id_pessoa = pb.id_pessoa
             LEFT JOIN Item_Doacao id ON d.id_doacao = id.id_doacao
             LEFT JOIN Item i ON id.id_item = i.id_item
             WHERE d.id_doacao = $1`,
            [id]
        );

        if (result.rows.length === 0) {
            return null;
        }

        const voluntario = new Voluntario(
            result.rows[0].id_voluntario,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco
        );

        const beneficiario = new Beneficiario(
            result.rows[0].id_beneficiario,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco,
            result.rows[0].renda
        );

        const itens = result.rows
            .filter(row => row.id_item)
            .map(row => new Item(
                row.id_item,
                row.tipo,
                row.descricao,
                row.tamanho,
                row.condicao,
                row.categoria,
                row.status
            ));

        return new Doacao(
            result.rows[0].id_doacao,
            voluntario,
            beneficiario,
            itens,
            new Date(result.rows[0].data_doacao),
            result.rows[0].tipo_doacao,
            result.rows[0].status,
            result.rows[0].observacoes
        );
    }

    async findAll(): Promise<Doacao[]> {
        const result = await this.pool.query(
            `SELECT d.*, v.*, b.*, i.*, pv.*, pb.*
             FROM Doacao d
             JOIN Voluntario v ON d.id_voluntario = v.id_voluntario
             JOIN Beneficiario b ON d.id_beneficiario = b.id_beneficiario
             JOIN Pessoa pv ON v.id_pessoa = pv.id_pessoa
             JOIN Pessoa pb ON b.id_pessoa = pb.id_pessoa
             LEFT JOIN Item_Doacao id ON d.id_doacao = id.id_doacao
             LEFT JOIN Item i ON id.id_item = i.id_item`
        );

        const doacoesMap = new Map<number, Doacao>();

        result.rows.forEach(row => {
            if (!doacoesMap.has(row.id_doacao)) {
                const voluntario = new Voluntario(
                    row.id_voluntario,
                    row.nome,
                    row.cpf,
                    row.telefone,
                    row.email,
                    row.endereco
                );

                const beneficiario = new Beneficiario(
                    row.id_beneficiario,
                    row.nome,
                    row.cpf,
                    row.telefone,
                    row.email,
                    row.endereco,
                    row.renda
                );

                const doacao = new Doacao(
                    row.id_doacao,
                    voluntario,
                    beneficiario,
                    [],
                    new Date(row.data_doacao),
                    row.tipo_doacao,
                    row.status,
                    row.observacoes
                );

                doacoesMap.set(row.id_doacao, doacao);
            }

            if (row.id_item) {
                const item = new Item(
                    row.id_item,
                    row.tipo,
                    row.descricao,
                    row.tamanho,
                    row.condicao,
                    row.categoria,
                    row.status
                );
                doacoesMap.get(row.id_doacao)?.getItens().push(item);
            }
        });

        return Array.from(doacoesMap.values());
    }

    async update(doacao: Doacao): Promise<Doacao> {
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');

            // Atualizar a doação
            const doacaoResult = await client.query(
                'UPDATE Doacao SET status = $1 WHERE id_doacao = $2 RETURNING *',
                [doacao.getStatus(), doacao.getId()]
            );

            // Remover itens antigos
            await client.query('DELETE FROM Item_Doacao WHERE id_doacao = $1', [doacao.getId()]);

            // Inserir novos itens
            for (const item of doacao.getItens()) {
                await client.query(
                    'INSERT INTO Item_Doacao (id_doacao, id_item, quantidade) VALUES ($1, $2, $3)',
                    [doacao.getId(), item.getId(), 1]
                );
            }

            await client.query('COMMIT');

            return new Doacao(
                doacaoResult.rows[0].id_doacao,
                doacao.getVoluntario(),
                doacao.getBeneficiario(),
                doacao.getItens(),
                new Date(doacaoResult.rows[0].data_doacao),
                doacaoResult.rows[0].tipo_doacao,
                doacaoResult.rows[0].status,
                doacaoResult.rows[0].observacoes
            );
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    async delete(id: number): Promise<void> {
        const client = await this.pool.connect();
        try {
            await client.query('BEGIN');
            await client.query('DELETE FROM Item_Doacao WHERE id_doacao = $1', [id]);
            await client.query('DELETE FROM Doacao WHERE id_doacao = $1', [id]);
            await client.query('COMMIT');
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }
} 