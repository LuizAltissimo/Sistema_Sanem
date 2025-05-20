import { BaseRepository } from './BaseRepository';
import { Pessoa } from '../models/Pessoa';

export class PessoaRepository extends BaseRepository<Pessoa> {
    async create(pessoa: Pessoa): Promise<Pessoa> {
        const result = await this.pool.query(
            'INSERT INTO Pessoa (nome, cpf, telefone, email, endereco) VALUES ($1, $2, $3, $4, $5) RETURNING *',
            [pessoa.getNome(), pessoa.getCpf(), pessoa.getTelefone(), pessoa.getEmail(), pessoa.getEndereco()]
        );
        return new Pessoa(
            result.rows[0].id_pessoa,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco
        );
    }

    async findById(id: number): Promise<Pessoa | null> {
        const result = await this.pool.query('SELECT * FROM Pessoa WHERE id_pessoa = $1', [id]);
        if (result.rows.length === 0) {
            return null;
        }
        return new Pessoa(
            result.rows[0].id_pessoa,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco
        );
    }

    async findAll(): Promise<Pessoa[]> {
        const result = await this.pool.query('SELECT * FROM Pessoa');
        return result.rows.map(row => new Pessoa(
            row.id_pessoa,
            row.nome,
            row.cpf,
            row.telefone,
            row.email,
            row.endereco
        ));
    }

    async update(pessoa: Pessoa): Promise<Pessoa> {
        const result = await this.pool.query(
            'UPDATE Pessoa SET nome = $1, cpf = $2, telefone = $3, email = $4, endereco = $5 WHERE id_pessoa = $6 RETURNING *',
            [pessoa.getNome(), pessoa.getCpf(), pessoa.getTelefone(), pessoa.getEmail(), pessoa.getEndereco(), pessoa.getId()]
        );
        return new Pessoa(
            result.rows[0].id_pessoa,
            result.rows[0].nome,
            result.rows[0].cpf,
            result.rows[0].telefone,
            result.rows[0].email,
            result.rows[0].endereco
        );
    }

    async delete(id: number): Promise<void> {
        await this.pool.query('DELETE FROM Pessoa WHERE id_pessoa = $1', [id]);
    }
} 